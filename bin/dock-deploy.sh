DIR="$ADEM_HOME"
USER=`whoami`
i=1

VO=$1
SITE_FILE=$2

if [ "X$VO" == "X" ]; then
  echo "(1)Please input the Virtual Organization name as the first parameter."
  echo "For osg, vo can be:CDF CMS CompBioGrid DES DOSAR DZero Engage Fermilab fMRI GADU geant4 GLOW GPN GRASE GridChem GridEx GROW i2u2 iVDGL LIGO mariachi MIS  nanoHUB NWICG  Ops  OSG OSGEDU SDSS STAR USATLAS. For Teragrid, vo just use: teragrid."
  echo "(2)And Please input the grid sites file as the second parameter.Just use a space to separate the parameters.You can use auto-get-sites to create the available grid sites file automatically."
  exit
fi

if [ "X$SITE_FILE" == "X" ]; then
  {
  echo "Oh,no grid sites file for the application deployment.Please input the grid sites file as the second parameter.You can use auto-get-sites to create the available grid sites automatically."
  }
  exit
fi

for SITE in $(awk '{print $1}' $SITE_FILE)
do
  echo $i
  echo $SITE
  APP=`sed -n "$i"p $SITE_FILE | awk {'print $2'}`
  PACMAN=`sed -n "$i"p $SITE_FILE | awk {'print $3'}`

  #To make a directory as a new pacman work directory/
  globus-job-run $SITE /bin/mkdir -p $APP/$VO/$USER/work-pac 2>/dev/null

  # To create the pacman install script
  echo "#/bin/sh" > $DIR/tmp/dock-$SITE.sh
  echo "cd  $APP/$VO/$USER/work-pac"  >> $DIR/tmp/dock-$SITE.sh
#  echo "export PATH=$APP/$VO/$USER/work-pac/gcc-3.4.3/bin:$APP/$VO/$USER/work-pac/flex-2.5.4/bin:$APP/$VO/$USER/work-pac/byacc-20070509/bin:/usr/bin:$PATH " >> $DIR/tmp/dock-$SITE.sh
#  echo "export LD_LIBRARY_PATH=$APP/$VO/$USER/work-pac/gcc-3.4.3/lib:/usr/lib:$LD_LIBRARY_PATH " >> $DIR/tmp/dock-$SITE.sh
  echo "source $PACMAN/setup.sh"  >> $DIR/tmp/dock-$SITE.sh
  echo "$PACMAN/bin/pacman -clear-lock" >> $DIR/tmp/dock-$SITE.sh
  echo "$PACMAN/bin/pacman -trust-all-caches -get http://www.ci.uchicago.edu/~houzx/pac-cache:dock"  >> $DIR/tmp/dock-$SITE.sh

  #make a timestamp for the deployment log
  echo "Starting `date`" >>$DIR/tmp/dock-deploy-$SITE-out.log
  echo "Starting `date`" >>$DIR/tmp/dock-deploy-$SITE-err.log

  # To transmit and execute the pacman install script to the given grid site
  #globus-job-run  $SITE  -stage $DIR/tmp/dock-$SITE.sh
  globus-url-copy  file://$DIR/tmp/dock-$SITE.sh  gsiftp://$SITE$APP/$VO/$USER/dock-$SITE.sh && globus-job-run  $SITE  /bin/sh $APP/$VO/$USER/dock-$SITE.sh 1>>$DIR/tmp/dock-deploy-$SITE-out.log 2>>$DIR/tmp/dock-deploy-$SITE-err.log && echo "Ending `date`" >>$DIR/tmp/dock-deploy-$SITE-out.log & 
  
  #to delete the tempory deploy file
  #/bin/rm -f $DIR/tmp/dock-$SITE.sh
  i=`expr $i + 1` 
done
echo "The standard output and error messge are respectively in $DIR/tmp/dock-deploy-SITE-out.log and $DIR/tmp/dock-deploy-SITE-err.log "
