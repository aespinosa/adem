require 'optparse'
require 'yaml'
require 'ftools'

require 'adem/config'
require 'adem/sites'
require 'adem/app'

CONFIGURATION_FILE = "#{ENV['HOME']}/.adem/config"
SITES_FILE         = "#{ENV['HOME']}/.adem/sites"
APPS_FILE          = "#{ENV['HOME']}/.adem/apps"

def run_command(args, config_file, sites_file)
  command = args.shift
  output = nil
  conf = config args, config_file
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
