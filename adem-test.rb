#!/usb/bin/env ruby

require 'test/unit'
require 'adem'
require 'yaml'

module Adem
  module TestSetup
    def setup
      @conf = {
        :pacman_cache         => "http://www.ci.uchicago.edu/~aespinosa/Cybershake",
        :ress_server          => "osg-ress-1.fnal.gov",
        :virtual_organization => "engage"
      }
      @site_list = File.open("sites").read
      @ress = File.open("dummy_ress").read
    end
  end
end

class OnlineTest < Test::Unit::TestCase
  include Adem::TestSetup

  def test_sites_live
    conf = @conf
    begin
      sites(nil, conf, "non_existent_file")
    rescue SiteError => e
      assert_equal YAML.load(@site_list), e.output
    end
  end

  def test_query_ress
    conf = @conf
    ress = query_ress(conf).split "\n\n"
    assumption = true
    class_ads = [
      "GlueSiteUniqueID", "GlueCEInfoHostName", "GlueCEInfoJobManager",
      "GlueCEInfoGatekeeperPort", "GlueSEAccessProtocolEndpoint",
      "GlueSEAccessProtocolType", "GlueCEInfoApplicationDir", "GlueCEInfoDataDir"
    ]
    missing = []
    ress.each do |entry|
      class_ads.each do |ad|
        assumption = assumption && entry.include?(ad)
        missing << ad if not entry.include?(ad)
      end
    end
    # False: there exist an entry without the expected classad.
    # Must report to osg support then
    assert assumption, "Missing attributes: \n\t#{missing.uniq.join(", ")}"
  end

  def test_app_avail
    pacman_cache = @conf[:pacman_cache]
    response = <<-eos
http://www.ci.uchicago.edu/~aespinosa/Cybershake
    [ ] jbsim3d
    eos
    assert_equal(response, app_avail(pacman_cache))
  end

  def test_pacman_find_firefly
    # Firefly
    site = {
      :compute_element => "ff-grid.unl.edu:2119/jobmanager-pbs",
      :app_directory => "/panfs/panasas/CMS/app"
    }
    assert_equal("/opt/pacman/pacman-3.28", pacman_find(site, @conf))
  end
end

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

  def test_parse_classads
    site_list = YAML.load @site_list
    assert_equal site_list, parse_classads(@ress.split("\n\n"))
  end

  def test_app
    conf = @conf
    assert_equal("app", app(nil, conf))
  end

  def test_config
    assert_equal(@conf, config(nil, "config"))
  end
end

class RunTest < Test::Unit::TestCase
  include Adem::TestSetup

  def test_config
    assert_equal(@conf, run_command(["config"], "config", nil))
  end

  def test_sites_from_file
    conf = @conf
    site_list = YAML.load @site_list
    assert_equal(site_list, run_command(["sites"], "config", "sites"))
  end
end
