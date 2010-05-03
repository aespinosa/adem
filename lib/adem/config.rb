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

def config(args, config_file)
  load_config File.open(config_file)
end
