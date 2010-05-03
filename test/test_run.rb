require 'setup_test'

class RunTest < Test::Unit::TestCase
  include Adem::TestSetup

  def test_config
    assert_equal(@conf, run_command(["config"], "config", nil))
  end

  def test_sites_from_file
    conf = @conf
    site_list = YAML.load @site_list
    conf[:sites] = site_list
    assert_equal(conf, run_command(["sites"], "config", "sites"))
  end
end
