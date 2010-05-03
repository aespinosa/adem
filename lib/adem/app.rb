require 'optparse'

def app(args, conf)
  options = {}
  optparse = OptionParser.new do |opts|
    opts.banner = "Usage: adem app [options]"

    opts.on('-l', '--avail', 'Available packages from cache') do
      puts "Packages available from #{conf[:pacman_cache]}"
      puts app_avail(conf[:pacman_cache]).grep /[(\ |\*)]/
    end

    opts.on('-i', '--install PACKAGE', 'Package to install') do |package|
      puts "Installing #{package}"
      app_install package, conf
    end

    opts.on_tail('-h', '--help', 'Show this help message') do
      puts opts
      exit
    end
  end
  optparse.parse!
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
