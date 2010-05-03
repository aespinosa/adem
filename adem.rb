#!/usr/bin/env ruby

# = ADEM: Application software DEployment and Management
# authors:: Zhengxiong Hou (original sh prototype)
#           Allan Espinosa (rewrite to ruby)

require 'yaml'

CONFIGURATION_FILE = "#{ENV['HOME']}/.adem/config"
SITES_FILE = "#{ENV['HOME']}/.adem/sites"

def load_config(yaml_config)
  YAML.load yaml_config
end

def query_ress(conf)
  File.open("dummy_ress").read.split '\n\n'
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
    #parse_classads query_ress conf
  end
end

def app(args, conf)
  "app"
end

def config(args)
  load_config File.open("config")
end

def run_command(args)
  command = args.shift
  if command != "config"
    conf = load_configuration File.open(CONFIGURATION_FILE)
    sites args, conf, File.open(SITES_FILE).read
  else
    config args
  end
end

if $0 == __FILE__
  run_command ARGV, conf
end
