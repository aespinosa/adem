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
