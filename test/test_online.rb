require 'setup_test'

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

  def test_ress_query
    conf = @conf
    ress = ress_query(conf).split "\n\n"
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
    pacman_cache = "test/dummy_cache"
    response = <<-eos
test/dummy_cache
    [ ] jbsim3d
    eos
    assert_equal(response, app_avail(pacman_cache))
  end

  def test_pacman_find_firefly
    # Firefly
    site = {
      :compute_element => "ff-grid.unl.edu:2119/jobmanager-pbs",
      :app_directory => "/panfs/panasas/CMS/app",
      :storage_element => "gsiftp://ff-gridftp.unl.edu:2811"
    }
    assert_equal(
      "/opt/pacman/pacman-3.28",
      pacman_find(
        "ff-grid.unl.edu/jobmanager-fork",
        "/panfs/panasas/CMS/app/engage"
      )
    )
  end

  def test_pacman_install_firefly_jbsim3d
    # Cleanup target first
    `globus-job-run ff-grid.unl.edu -env PACMAN_LOCATION=/opt/pacman/pacman-3.28 -d /panfs/panasas/CMS/app/engage /opt/pacman/pacman-3.28/bin/pacman -remove jbsim3d`
    expected = <<-eos
  jbsim3d found in http://www.ci.uchicago.edu/~aespinosa/Cybershake...
  Installing jbsim3d...
  Downloading jbsim3d_r794~RHEL5_amd64.tar.gz...
  Untarring jbsim3d_r794~RHEL5_amd64.tar.gz...
  jbsim3d has been installed.
    eos
    assert_equal(
      expected,
      pacman_install(
        "http://www.ci.uchicago.edu/~aespinosa/Cybershake:jbsim3d",
        { :contact => "ff-grid.unl.edu/jobmanager-fork",
          :pacman  => "/opt/pacman/pacman-3.28",
          :path    => "/panfs/panasas/CMS/app/engage" }
      )
    )
  end

  def test_pacman_remove_firefly_jbsim3d
    expected = <<-eos
  Uninstalling jbsim3d...
  Removing /panfs/panasas/CMS/app/engage/jbsim3d_r794~RHEL5_amd64.tar.gz contents...
  jbsim3d has been uninstalled.
    eos
    assert_equal(
      expected,
      pacman_remove(
        "jbsim3d",
        { :contact => "ff-grid.unl.edu/jobmanager-fork",
          :pacman  => "/opt/pacman/pacman-3.28",
          :path    => "/panfs/panasas/CMS/app/engage" }
      )
    )
  end
end
