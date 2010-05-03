require 'setup_test'

class OfflineTest < Test::Unit::TestCase
  include Adem::TestSetup

  def test_sites_exception
    conf = @conf
    conf[:ress_server] = nil
    site_list = YAML.load @site_list
    def ress_query(x)
      ""
    end
    assert_raise SiteError do
      sites(nil, conf, "non_existent_file")
    end
  end

  def test_sites_from_file
    conf = @conf
    site_list = YAML.load @site_list
    assert_equal(site_list, sites(nil, conf, "test/dummy_sites"))
  end

  def test_site_fork
    assert_equal "ff-grid.unl.edu:2119/jobmanager-fork", site_fork("ff-grid.unl.edu:2119/jobmanager-pbs")
  end

  def test_ress_parse
    site_list = YAML.load @site_list
    assert_equal site_list, ress_parse(@ress.split("\n\n"))
  end

  def test_app
    conf = @conf
    assert_equal("app", app(nil, conf))
  end

  def test_app_avail
    pacman_cache = "test/dummy_cache"
    response = <<-eos
test/dummy_cache
    [ ] jbsim3d
    eos
    assert_equal(response, app_avail(pacman_cache))
  end

  def test_config
    assert_equal(@conf, config(nil, "test/dummy_config"))
  end

  def test_config_load
    assert_equal(@conf, config_load(File.open("test/dummy_config").read))
  end

  def test_config_check
    exception = assert_raise ConfigError do
      config_check({})
    end
    assert_match /RESS server/, exception.message
    exception = assert_raise ConfigError do
      config_check({:ress_server => "foo"})
    end
    assert_match /Pacman cache/, exception.message
    exception = assert_raise ConfigError do
      config_check({:ress_server => "foo", :pacman_cache => "bar"})
    end
    assert_match /Virtual organization/, exception.message
  end
end
