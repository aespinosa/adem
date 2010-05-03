#!/usr/bin/env ruby

# = ADEM: Application software DEployment and Management
# Author::       Zhengxiong Hou (original sh prototype)
# Author:: Allan Espinosa (rewrite to ruby)
#

require 'yaml'

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

def query_ress(conf)
  `condor_status -pool #{conf[:ress_server]} -const \
    'stringListIMember(\"VO:#{conf[:virtual_organization]}\", \  
    GlueCEAccessControlBaseRule)' -long`
end

def parse_classads(ress)
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

def sites(args, conf, sites_file)
  begin
    YAML.load File.open sites_file
  rescue Errno::ENOENT
    result = parse_classads query_ress(conf).split("\n\n")
    raise SiteError.new(result)
  end
end

def app(args, conf)
  "app"
end

def config(args, config_file)
  load_config File.open(config_file)
end

def run_command(args)
  command = args.shift
  if command != "config"
    conf = load_config File.open(CONFIGURATION_FILE)
    puts sites(args, conf, SITES_FILE).to_yaml if command == "sites"
  else
    config args, CONFIGURATION_FILE
  end
end

if $0 == __FILE__
  run_command ARGV
end
