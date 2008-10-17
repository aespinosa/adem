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
  Signature=`sed -n "$i"p $SITE_FILE | awk {'print $4'} | cut -d- -f1,2`

  #To make a directory as a new pacman work directory/
  globus-job-run $SITE /bin/mkdir -p $APP/$VO/$USER/work-pac 2>/dev/null

  # To create the pacman install script
  if [  -f $DIR/tmp/freesurfer-$SITE.sh ]; then
     rm -f $DIR/tmp/freesurfer-$SITE.sh
  fi
  echo "#/bin/sh" >> $DIR/tmp/freesurfer-$SITE.sh
  echo "cd  $APP/$VO/$USER/work-pac"  >> $DIR/tmp/freesurfer-$SITE.sh
  echo "source $PACMAN/setup.sh"  >> $DIR/tmp/freesurfer-$SITE.sh
  echo "$PACMAN/bin/pacman -clear-lock" >> $DIR/tmp/freesurfer-$SITE.sh
  echo "$PACMAN/bin/pacman -trust-all-caches -get http://www.ci.uchicago.edu/~houzx/pac-cache:freesurfer-$Signature"  >> $DIR/tmp/freesurfer-$SITE.sh

  #make a timestamp for the deployment log
  echo "Starting `date`" >>$DIR/tmp/freesurfer-deploy-$SITE-out.log
  echo "Starting `date`" >>$DIR/tmp/freesurfer-deploy-$SITE-err.log

  # To transmit and execute the pacman install script to the given grid site
  #globus-job-run  $SITE  -stage $DIR/tmp/freesurfer-$SITE.sh
  globus-url-copy  file://$DIR/tmp/freesurfer-$SITE.sh  gsiftp://$SITE$APP/$VO/$USER/freesurfer-$SITE.sh && globus-job-run  $SITE  /bin/sh $APP/$VO/$USER/freesurfer-$SITE.sh 1>>$DIR/tmp/freesurfer-deploy-$SITE-out.log 2>>$DIR/tmp/freesurfer-deploy-$SITE-err.log && echo "Ending `date`" >>$DIR/tmp/freesurfer-deploy-$SITE-out.log &
  #globus-url-copy  file:///home/houzx/public_html/pac-cache/freesurfer.license gsiftp://$SITE$APP/$VO/$USER/work-pac/freesurfer/freesurfer.license
  #to delete the tempory deploy file

  i=`expr $i + 1` 
done

echo "Please see the standard output and error messages in $DIR/tmp/freesurfer-deploy-SITE-out.log $DIR/tmp/freesurfer-deploy-SITE-err.log"
