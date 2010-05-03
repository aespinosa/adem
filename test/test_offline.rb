require 'setup_test'

class OfflineTest < Test::Unit::TestCase
  include Adem::TestSetup

  def test_sites_exception
    conf = @conf
    conf[:ress_server] = nil
    site_list = YAML.load @site_list
    assert_raise SiteError do
      sites(nil, conf, "non_existent_file")
    end
  end

  def test_sites_from_file
    conf = @conf
    site_list = YAML.load @site_list
    assert_equal(site_list, sites(nil, conf, "sites"))
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

  def test_config
    assert_equal(@conf, config(nil, "config"))
  end
end
