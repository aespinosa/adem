#!/bin/bash
#
# set-up environment to run Adem - source me
#

dir=`basename $PWD`
Def_Rep="http://www.ci.uchicago.edu/~houzx/pac-cache"

if [ "X${GLOBUS_LOCATION}" == "X" ]; then
   echo "NO GLOBUS Error!"

else if [ $dir != "adem-osg" ]; then
   echo "Please cd to adem-osg for first setup!"
   
   else if [ "X${ADEM_HOME}" == "X" ] || [ "${ADEM_HOME}" != "$PWD" ]; then
           export ADEM_HOME=$PWD
           export PATH=$PATH:$ADEM_HOME/bin
        fi
  fi
fi

#check the grid proxy
grid-proxy-info 1>/dev/null 2>/dev/null
if [ "$?" != 0 ]; then
  echo "ERROR: Couldn not find a valid proxy, Please check your grid proxy!"
  else 
  {
  timel=`grid-proxy-info  |grep timeleft |cut -d: -f2`
  if [ "$timel" -lt 1 ]; then
  echo "Warning, Proxy has less than 60 minutes remaining."
  fi
  }
fi

#check pacman
if [ "X$PACMAN_LOCATION" == "X" ]; then
/bin/tar -C $ADEM_HOME  -zxf $ADEM_HOME/doc/pacman-3.21.tar.gz
DIR=$PWD
cd $ADEM_HOME/pacman-3.21
source setup.sh 2>/dev/null
cd $DIR
fi

#check application software repository
if [ "X$REPOSITORY_HOME" == "X" ]; then
   echo "The default application software repository is:"
   echo "$Def_Rep"
   echo "Do you want to set up your own repository?y or n"
   read response
   if [ "$response" == "y" ];then
   echo "Please input your own application software repository:"
   read rep
   echo "OK, you should maintain your own repository, to add,update,or remove the pacman files and software packages."
   export REPOSITORY_HOME=$rep
   else
   export REPOSITORY_HOME=$Def_Rep
   fi
fi
