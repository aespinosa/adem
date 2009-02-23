#/bin/bssh!
DIR="$ADEM_HOME"

SITE=$1
Name=$2

if [ "X$SITE" == "X" ] || [ "X$Name" == "X" ]; then
echo "This is for the checking of executables, it is related with swift-auto-tc-data, needs the SITE Gatekeeper and Site Name as two parameters."
exit
fi
  
  echo "#" "$SITE" > $DIR/tmp/swift-app-tc-$SITE.data
  echo "#"  >>  $DIR/tmp/swift-app-tc-$SITE.data

  for Dbin in $(cat $DIR/tmp/work-pac-bin-$SITE.log)
  do
     {
         globus-job-run $SITE /bin/ls $Dbin 2>/dev/null > $DIR/tmp/executables-$SITE.log
         for EXE in $(cat $DIR/tmp/executables-$SITE.log)
         do
         {
         echo "$Name    $EXE    $Dbin/$EXE      INSTALLED       INTEL32::LINUX  null" >>$DIR/tmp/swift-app-tc-$SITE.data
         }
         done
     }
  done
