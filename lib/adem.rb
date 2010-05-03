#!/usr/bin/env ruby

# = ADEM: Application software DEployment and Management
# Author::       Zhengxiong Hou (original sh prototype)
# Author:: Allan Espinosa (rewrite to ruby)
#

require 'yaml'
require 'ftools'

CONFIGURATION_FILE = "#{ENV['HOME']}/.adem/config"
SITES_FILE         = "#{ENV['HOME']}/.adem/sites"
APPS_FILE          = "#{ENV['HOME']}/.adem/apps"

class SiteError < Exception
  attr_reader :output
  def initialize(output)
    @output = output
  end
end

class ConfigError < RuntimeError
end

def load_config(yaml_config)
  conf = YAML.load yaml_config
  conf.each do |key, val|
    conf.delete(key)
    conf[key.to_sym] = val
  end
  conf
end

def sites(args, conf, sites_file)
  begin
    YAML.load File.open sites_file
  rescue Errno::ENOENT
    result = ress_parse ress_query(conf).split("\n\n")
    raise SiteError.new(result)
  end
end

def ress_query(conf)
  `condor_status -pool #{conf[:ress_server]} -const \
    'stringListIMember(\"VO:#{conf[:virtual_organization]}\", \  
    GlueCEAccessControlBaseRule)' -long`
end

def ress_parse(ress)
  class_ads = [
    "GlueSiteUniqueID", "GlueCEInfoHostName", "GlueCEInfoJobManager",
    "GlueCEInfoGatekeeperPort", "GlueSEAccessProtocolEndpoint",
    "GlueSEAccessProtocolType", "GlueCEInfoApplicationDir", "GlueCEInfoDataDir"
  ]
  site = {}
  ress.each do |entry|
    tmp = {}
    entry.each do |attr|
      attr.chomp!
      class_ads.each do |class_ad|
        if attr.include? class_ad
          tmp[class_ad] = attr.gsub!(/.*\=\ (.*)$/, '\1').gsub /"/, ''
        end
      end
    end

    next if tmp["GlueSiteUniqueID"] == nil
    site_name = tmp["GlueSiteUniqueID"]
    site[site_name] = {} if site[site_name] == nil

    compute_element = "#{tmp['GlueCEInfoHostName']}:#{tmp['GlueCEInfoGatekeeperPort']}/jobmanager-#{tmp['GlueCEInfoJobManager']}"
    if site[site_name]["compute_element"] == nil
      site[site_name]["compute_element"] = compute_element
    elsif site[site_name]["compute_element"] != compute_element
      old = site[site_name]["compute_element"].to_a
      old << compute_element
      site[site_name]["compute_element"] = old.uniq
    end
    storage_element = "gsiftp://#{tmp['GlueCEInfoHostName']}:2811"
    if site[site_name]["storage_element"] == nil
      site[site_name]["storage_element"] = storage_element
    elsif site[site_name]["storage_element"] != storage_element
      old = site[site_name]["storage_element"].to_a
      old << storage_element
      site[site_name]["storage_element"] = old.flatten.uniq
    end
    site[site_name]["data_directory"] = tmp['GlueCEInfoDataDir']
    site[site_name]["app_directory"] = tmp['GlueCEInfoApplicationDir']

    # Disabled because some storage endpoints are broken
    #storage_element = tmp['GlueSEAccessProtocolEndpoint'] if tmp['GlueSEAccessProtocolType'] == 'gsiftp'
    #next if storage_element == nil
    #if storage_element.include? ','
      #storage_element = storage_element.split(',').grep /gsiftp/
    #end
    #if site[site_name]["storage_element"] == nil
      #site[site_name]["storage_element"] = storage_element
    #elsif site[site_name]["storage_element"] != storage_element
      #old = site[site_name]["storage_element"].to_a
      #old << storage_element
      #site[site_name]["storage_element"] = old.flatten.uniq
    #end
  end
  site
end

def app(args, conf)
  "app"
end

def app_avail(pacman_cache)
  `pacman -trust-all-caches -lc #{pacman_cache}`
end

def app_deploy(app, conf)
  conf[:sites].each do |site|
    path = "#{site[:app_directory]}/#{conf[:virtual_organization]}"
    contact = site_fork site[:compute_element]
    site[:pacman] = pacman_find(contact, path) if not site[:pacman] 
    target = {
      :contact => contact,
      :pacman => site[:pacman],
      :path => path
    }
    package = "#{conf[:pacman_cache]}:#{app}"
    pacman_install package, target 
  end
end

def site_fork(compute_element)
  compute_element.gsub /jobmanager-.*$/, "jobmanager-fork"
end

def pacman_find(contact, rootdir)
  File.open("find_pacman.sh", "w") do |dump|
    dump.puts "#!/bin/bash"
    dump.puts "which pacman"
  end
  File.chmod 0755, "find_pacman.sh"
  resp = `globus-job-run #{contact} -d #{rootdir} -stage find_pacman.sh`
  File.delete "find_pacman.sh"
  File.dirname(File.dirname(resp))
end

def pacman_install(package, target)
  File.open("pacman_install.sh", "w") do |dump|
    dump.puts "#!/bin/bash"
    dump.puts "source #{target[:pacman]}/setup.sh"
    dump.puts "pacman -trust-all-caches -install #{package}"
  end
  File.chmod 0755, "pacman_install.sh"
  `globus-job-run #{target[:contact]} /bin/mkdir -p #{target[:path]}`
  resp = `globus-job-run #{target[:contact]} -d #{target[:path]} -stage pacman_install.sh`
  File.delete "pacman_install.sh"
  resp
end

def config(args, config_file)
  load_config File.open(config_file)
end

def run_command(args, config_file, sites_file)
  command = args.shift
  output = nil
  conf = load_config File.open(config_file)
  return conf if command == "config"
  begin
    site_args = nil
    site_args = args if command == "sites"
    conf[:sites] = sites(site_args, conf, sites_file)
  rescue SiteError => exception
    conf[:sites] = exception.output
    File.open(sites_file, "w") do |sites_file|
      sites_file << output.to_yaml
    end
  end
  return conf if command == "sites"
  app(args, conf) if command == "app"
end

if $0 == __FILE__
  run_command ARGV, CONFIGURATION_FILE, SITES_FILE
end
