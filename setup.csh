#!/bin/csh
#
# set-up environment to run Adem - source me
#

dir=`basename ${PWD}`
Def_Rep="http://www.ci.uchicago.edu/~houzx/pac-cache"

if ("X${GLOBUS_LOCATION}" == "X") then
   echo "NO GLOBUS Error!"
 else if (${dir} != "adem-osg") then
   echo "Please cd to adem-osg for first setup!"
   
   else if ("X${ADEM_HOME}" == "X")||("${ADEM_HOME}" != "${PWD}")  then
   setenv ADEM_HOME ${PWD}
   setenv PATH ${PATH}:${PWD}/bin
   endif
 endif
endif

#check the grid proxy
grid-proxy-info 1>/dev/null 2>/dev/null
if ("$?" != 0) then
  echo "ERROR: Couldn not find a valid proxy, Please check your grid proxy!"
  exit 1
  else
  {
  timel=`grid-proxy-info  |grep timeleft |cut -d: -f2`
  if ("$timel" -lt 1) then
  echo "Proxy has less than 60 minutes remainging - exiting."
  exit
  endif
  }
endif

#check pacman
if ("X${PACMAN_LOCATION}" == "X") then
  /bin/tar -C ${ADEM_HOME}  -zxf ${ADEM_HOME}/doc/pacman-3.21.tar.gz
  DIR=${PWD}
  cd ${ADEM_HOME}/pacman-3.21
  source setup.csh 2>/dev/null
  cd ${DIR}
endif

#check application software repository
if ("X${REPOSITORY_HOME}" == "X") then
   echo "The default application software repository is:"
   echo "${Def_Rep}"
   echo "Do you want to set up your own repository?y or n"
   read response
   if ("${response}" == "y") then
   echo "Please input your own application software repository:"
   read rep
   echo "OK, you should maintain your own repository, to add,update,or remove the pacman files and software packages."
   setenv REPOSITORY_HOME ${rep}
   else
   setenv REPOSITORY_HOME ${Def_Rep}
   endif
endif
