#!/bin/bash

# vors_client.output sitesdir(1/2/3/4) jobThrottle

declare -a SITE1

SITE1=("gate01.aglt2.org" "cit-gatekeeper.ultralight.org" "cmsgrid01.hep.wisc.edu" "cmsgrid02.hep.wisc.edu" "piranha.ie.lehigh.edu" "ce01.cmsaf.mit.edu" "condor.hpcc.nd.edu" "u2-grid.ccr.buffalo.edu" "cms-xen2.fnal.gov" "osg-ligo.mit.edu" "grid3.aset.psu.edu" "julius.rcac.purdue.edu" "smufarm.physics.smu.edu" "osg-ce.sprace.org.br" "gk01.atlas-swt2.org" "antaeus.hpcc.ttu.edu" "saxon.hosted.ats.ucla.edu" "atlas.dpcc.uta.edu" "abitibi.sbgrid.org" "osg-gw-2.t2.ucsd.edu" "osg-gw-4.t2.ucsd.edu" "spgrid.if.usp.br" "uscms1.fltech-grid3.fit.edu")

declare -a DATA1
DATA1=("/atlas/data08/OSG/DATA" "/raid2/osg-data" "/afs/hep.wisc.edu/osg/data" "/afs/hep.wisc.edu/osg/data" "/home/osg/data" "/osg/data" "/dscratch/osg/data" "/san/scratch/grid/grid-tmp/grid-data" "/usr/local/osg-ce/OSG.DIRS/data" "/opt/storage/data" "/usr1/grid3/data" "/scratch/caesar/data" "/data" "/home/OSG_app/data" "/cluster/grid/data" "/mnt/hep/osg" "/u/osgdata" "/data73/osg/data" "/se/data/vo" "/osgfs/data" "/osgfs/data" "/home/OSG_app/data" "/mnt/nas0/OSG/DATA")

declare -a SITE2

SITE2=("proton.fis.cinvestav.mx" "red.unl.edu" "iogw1.hpc.ufl.edu" "gk04.swt2.uta.edu" "tp-osg.uchicago.edu" "grow.cs.uni.edu")

declare -a DATA2
DATA2=("/raid/osg_data" "/opt/osg/data" "/scratch/ufhpc/osg/data" "/ifs1/osg/data" "/gpfs1/osg/data" "/data")

declare -a SITEDIR1
SITEDIR1=("AGLT2" "CIT_CMS_T2" "GLOW" "GLOW-CMS" "Lehigh_coral" "MIT_CMS" "NWICG_NDCCL" "NYSGRID-CCR-U2" "OSG_INSTALL_TEST_2" "OSG_LIGO_MIT" "OSG_LIGO_PSU" "Purdue-Caesar" "SMU_PHY" "SPRACE" "SWT2_CPB" "TTU-ANTAEUS" "UCLA_Saxon_Tier3" "UTA_DPCC" "SBGrid-Harvard-Exp" "UCSDT2" "UCSDT2-B" "SPRACE-CE" "FLTECH")

declare -a SITEDIR2
SITEDIR2=("cinvestav" "Nebraska" "UFlorida-HPC" "UTA_SWT2" "UC_Teraport" "GROW-UNI-P")

declare LOCAL_DIR="/home/lixi/osg/sitesfile/SELECT"
declare SITES_DIR="/home/lixi/osg/logs"

declare -i i
declare -i count
 
rm -rf $LOCAL_DIR/$2/sites.xml

echo '<config>'>>$LOCAL_DIR/$2/sites.xml
echo "" >>$LOCAL_DIR/$2/sites.xml
echo "<!-- sites.xml specifies details of the sites that Swift can run on." >>$LOCAL_DIR/$2/sites.xml
echo "" >>$LOCAL_DIR/$2/sites.xml
echo "The first entry entry, for localhost, should work on most linux-like systems">>$LOCAL_DIR/$2/sites.xml
echo "without any change.">>$LOCAL_DIR/$2/sites.xml
echo "" >>$LOCAL_DIR/$2/sites.xml
echo "It may be necessary to change the two occurences of /var/tmp to a different
working directory.">>$LOCAL_DIR/$2/sites.xml
echo "" >>$LOCAL_DIR/$2/sites.xml
echo "-->">>$LOCAL_DIR/$2/sites.xml
echo "" >>$LOCAL_DIR/$2/sites.xml
echo "<!-- The remainder of this file is commented out by default. It contains">>$LOCAL_DIR/$2/sites.xml
echo "example site definitions for a number of sites on TeraGrid and OSG.">>$LOCAL_DIR/$2/sites.xml
echo "" >>$LOCAL_DIR/$2/sites.xml
echo "How this list was constructed:">>$LOCAL_DIR/$2/sites.xml
echo "" >>$LOCAL_DIR/$2/sites.xml
echo "1. Teragrid">>$LOCAL_DIR/$2/sites.xml
echo "http://www.teragrid.org/userinfo/hardware/resources.php">>$LOCAL_DIR/$2/sites.xml
echo "fill out the gatekeeper info and the gridftp hostname">>$LOCAL_DIR/$2/sites.xml
echo "for the storage/workspace, login into the machine, and make yourself a">>$LOCAL_DIR/$2/sites.xml
echo "temporary directory">>$LOCAL_DIR/$2/sites.xml
echo "" >>$LOCAL_DIR/$2/sites.xml
echo "2. OSG">>$LOCAL_DIR/$2/sites.xml
echo "http://osg-cat.grid.iu.edu/index.php?site_name=osgcat">>$LOCAL_DIR/$2/sites.xml
echo "sort by CPUs">>$LOCAL_DIR/$2/sites.xml
echo "Add the gatekeeper hostname into the jobmanager name and into the gridftp url">>$LOCAL_DIR/$2/sites.xml
echo "Add the ($TMP) or ($WNTMP) to the storage element in the gridftp url AND">>$LOCAL_DIR/$2/sites.xml
echo "into the workspace element">>$LOCAL_DIR/$2/sites.xml
echo "" >>$LOCAL_DIR/$2/sites.xml
echo "TODO by user:">>$LOCAL_DIR/$2/sites.xml
echo "customize the storage and workdirectory to use your personal working directories">>$LOCAL_DIR/$2/sites.xml
echo "" >>$LOCAL_DIR/$2/sites.xml
echo "-->">>$LOCAL_DIR/$2/sites.xml
echo "" >>$LOCAL_DIR/$2/sites.xml
echo "<!-- OSGEDU SITES -->">>$LOCAL_DIR/$2/sites.xml
echo "" >>$LOCAL_DIR/$2/sites.xml

for ((i=0 ; i<${#SITE1[*]}; i++)); do
   status=$(grep ",${SITEDIR1[$i]}," $1 | awk -F"," '{print $6}') 
   if [ "$status" = "PASS" ]; then
    if test -s $SITES_DIR/${SITEDIR1[$i]}/job.score ; then
      score=$(cat $SITES_DIR/${SITEDIR1[$i]}/job.score)
      part=$(echo "scale=0; ($score+1)/1" | bc)
      factor=$(echo "scale=0; ($score*100)/1" | bc)
        if [ "$score" != "0" ] &&  test $part -gt 0 && test $factor -gt 0 ; then
          count=count+1
          echo '<pool handle="'${SITEDIR1[$i]}'">' >>$LOCAL_DIR/$2/sites.xml
          echo '  <gridftp  url="gsiftp://'${SITE1[$i]}'" />'>>$LOCAL_DIR/$2/sites.xml
          echo '  <jobmanager universe="vanilla" url="'${SITE1[$i]}'/jobmanager-condor" major="2" />' >>$LOCAL_DIR/$2/sites.xml          
          echo '  <workdirectory>'${DATA1[$i]}'</workdirectory>' >>$LOCAL_DIR/$2/sites.xml
          echo '  <profile namespace="karajan" key="initialScore">'$score'</profile>' >>$LOCAL_DIR/$2/sites.xml
          echo '  <profile namespace="karajan" key="jobThrottle">'$3'</profile>' >>$LOCAL_DIR/$2/sites.xml 
	  echo "</pool>" >>$LOCAL_DIR/$2/sites.xml
          echo "" >>$LOCAL_DIR/$2/sites.xml
        fi 
    fi
  fi
done

for ((i=0 ; i<${#SITE2[*]}; i++)); do
  status=$(grep ",${SITEDIR2[$i]}," $1 | awk -F"," '{print $6}')
  if [ "$status" = "PASS" ]; then
    if test -s $SITES_DIR/${SITEDIR2[$i]}/job.score ; then
      score=$(cat $SITES_DIR/${SITEDIR2[$i]}/job.score)
      part=$(echo "scale=0; ($score+1)/1" | bc)
      factor=$(echo "scale=0; ($score*100)/1" | bc)
        if [ "$score" != "0" ] &&  test $part -gt 0 && test $factor -gt 0  ; then
          count=count+1
          echo '<pool handle="'${SITEDIR2[$i]}'">' >>$LOCAL_DIR/$2/sites.xml
          echo '  <gridftp  url="gsiftp://'${SITE2[$i]}'" />'>>$LOCAL_DIR/$2/sites.xml
          echo '  <jobmanager universe="vanilla" url="'${SITE2[$i]}'/jobmanager-pbs" major="2" />' >>$LOCAL_DIR/$2/sites.xml
          echo '  <workdirectory>'${DATA2[$i]}'</workdirectory>' >>$LOCAL_DIR/$2/sites.xml
          echo '  <profile namespace="karajan" key="initialScore">'$score'</profile>' >>$LOCAL_DIR/$2/sites.xml 
	  echo '  <profile namespace="karajan" key="jobThrottle">'$3'</profile>' >>$LOCAL_DIR/$2/sites.xml
          echo "</pool>" >>$LOCAL_DIR/$2/sites.xml
          echo "" >>$LOCAL_DIR/$2/sites.xml
        fi 
    fi
  fi
done

echo "" >>$LOCAL_DIR/$2/sites.xml
echo "</config>" >>$LOCAL_DIR/$2/sites.xml

echo "This time $count sites are generated in sites.xml" >$LOCAL_DIR/$2/sitescount.txt
