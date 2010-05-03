#!/usb/bin/env ruby

require 'test/unit'
require 'adem'
require 'yaml'

class AdemTest < Test::Unit::TestCase

  def test_sites_from_file
    conf = @conf
    site_list = YAML.load @site_list
    assert_equal(site_list, sites(nil, conf, "sites"))
  end

  def test_sites_exception
    conf = @conf
    site_list = YAML.load @site_list
    begin
      sites(nil, conf, "non_existent_file")
    rescue Errno::ENOENT
      assert true, "Received exception"
    end
  end

  def test_parse_classads
    site_list = YAML.load @site_list
    assert_equal site_list, parse_classads(@ress)
  end

  def test_app
    conf = @conf
    assert_equal("app", app(nil, conf))
  end

  def test_config
    assert_equal(@conf, config(nil))
  end

  def setup
    @conf = {
      "pacman_cache"         => "http://www.ci.uchicago.edu/~aespinosa/pacman",
      "ress_server"          => "osg-ress-1.fnal.gov",
      "virtual_organization" => "engage"
    }
    @site_list = File.open("sites").read
    #@site_list.gsub! /^\s+/, ''
    @ress = File.open("dummy_ress").read.split "\n\n"
  end
end
