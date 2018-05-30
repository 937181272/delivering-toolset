#!/bin/bash

__ScriptName="offline_update_admin.sh"

#-----------------------------------------------------------------------  
# FUNCTION: usage  
# DESCRIPTION:  Display usage information.  
#-----------------------------------------------------------------------  
usage() {
  cat << EOT
    Usage :  ${__ScriptName} [OPTION] ...
      Build app from given options.
      
    Required Options:  
      --help									display help message
      --source-dir=SOURCE_DIR    	source installation file dir
      --release-version=NEW_VERSION				new version,eg:0.0.2
      --srv-ip=CTA_SRV_IP                 srv ip


      Exit status:
      0   if OK,
      !=0 if serious problems.
      
    Example:
      1) Use long options to build app:
        $ sudo bash $__ScriptName --source-dir=test --release-version=0.0.2 --srv-ip=192.168.1.1
EOT
}

WORKSPACE=/home/devops1/sk
APP_NAME=medicalbrain-cta-admin
RELEASE_SERVER_USER=devops1
SOURCE_DIR=
NEW_VERSION=
CTA_SRV_IP=

# parse options:  
RET=`getopt -o hp:v:i: -a -l help,release-user:,source-dir:,release-version:,srv-ip: -n 'ERROR' -- "$@"`

if [ $? != 0 ] ; then echo "$__ScriptName exited with doing nothing." >&2 ; exit 1 ; fi

# Note the quotes around $RET: they are essential!
eval set -- "$RET"

# set option values
while true; do
    case "$1" in
        -h|--help ) usage; exit 1;;

        -p|--source-dir ) SOURCE_DIR=$2
       shift 2 ;;

        -v|--release-version ) NEW_VERSION=$2
       echo "new version is: $NEW_VERSION"
       shift 2 ;;

       -i|--srv-ip ) CTA_SRV_IP=$2
       echo "cta srv is: $CTA_SRV_IP"
       shift 2 ;;

        -- ) shift; break ;;
        * ) echo "$1 is not option" ; exit 1 ;;
	esac
done

if [[ -z $SOURCE_DIR ]]; then
  usage
  exit 1
fi

if [[ -z $NEW_VERSION ]]; then
  usage
  exit 1
fi

if [[ -z $CTA_SRV_IP ]]; then
  usage
  exit 1
fi

cd $WORKSPACE

export BASE_URL="http://$CTA_SRV_IP:5000"
export LOGIN_URL="http://$CTA_SRV_IP:6986"
export DOCTOR_URL="http://$CTA_SRV_IP:6987"
export POSTPROC_URL="http://$CTA_SRV_IP:7989"
export AUTH_BASE_URL="http://$CTA_SRV_IP:5000"
export AUTH_MODE='local'

echo "download $NEW_VERSION botree"
rm -rf $APP_NAME-$NEW_VERSION.tar.gz
cp $SOURCE_DIR/$APP_NAME-$NEW_VERSION.tar.gz .

#echo pre_version=$(cat ./$APP_NAME/.version)
echo "backup previous version $pre_version"
mv $APP_NAME $APP_NAME.bak
rm -rf $APP_NAME.bak
if [[ -d $APP_NAME ]]; then
  mv $APP_NAME $APP_NAME.bak
fi

echo "unzip app $APP_NAME"
tar -xf $APP_NAME-$NEW_VERSION.tar.gz
cd $WORKSPACE/$APP_NAME
./install.sh

#TODO check if frontend is started up
echo " > rm tar package "
cd ..
rm -rf $APP_NAME-$NEW_VERSION.tar.gz

echo '*************************'
echo 'the updated version is : '
cat $APP_NAME/VERSION
echo '*************************'

