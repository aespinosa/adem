require 'fileutils'

class ConfigError < RuntimeError
end

def config(args, config_file)
  options = {}
  conf_new = {}
  optparse = OptionParser.new do |opts|
    opts.banner = 'Usage: adem config [options]'

    opts.on(nil, '--ress-server SERVER', 'RESS server name') do |server|
      conf_new[:ress_server] = server
    end

    opts.on(nil, '--pacman-cache CACHE', 'Location of pacman cache') do |cache|
      conf_new[:pacman_cache] = cache
    end

    opts.on(nil, '--virtual-organization VO', 'Name of virtual organization') do |vo|
      conf_new[:virtual_organization] = vo
    end

    opts.on(nil, '--display', 'Display current configuration') do 
      options[:display] = true
    end

    opts.on_tail('-h', '--help', 'Show this message') do
      puts opts
      exit
    end
  end
  optparse.parse!

  conf_yaml = nil
  conf = nil
  begin
    conf_yaml = File.open(config_file).read
    conf = config_load conf_yaml
    if options[:display]
      puts conf_yaml
      exit
    end
  rescue  Errno::ENOENT
    # must be complete if we are creating a new file
    config_check conf_new
  end
  conf.merge!(conf_new)
  config_update config_file if not conf_new.empty?
  conf
end

def config_load(yaml_config)
  conf = YAML.load yaml_config
  conf.each do |key, val|
    conf.delete(key)
    conf[key.to_sym] = val
  end
  conf
end

def config_check conf
  raise ConfigError, "RESS server missing" if not conf[:ress_server]
  raise ConfigError, "Pacman cache missing" if not conf[:pacman_cache]
  raise ConfigError, "Virtual organization missing" if not conf[:virtual_organization]
end

def config_update config_file
  FileUtils.mkdir_p File.dirname(config_file)
  File.open(config_file, "w") do |dump|
    dump << conf.to_yaml
  end
end
