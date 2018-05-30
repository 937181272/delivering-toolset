#!/bin/bash
set -ex
__ScriptName="offline_update_cta.sh"

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



      Exit status:
      0   if OK,
      !=0 if serious problems.
      
    Example:
      1) Use long options to build app:
        $ sudo $__ScriptName --source-dir=test --release-version=0.0.2 
EOT
}

WORKSPACE=/home/devops1/sk
SOURCE_DIR=
NEW_VERSION=

# parse options:  
RET=`getopt -o hp:v:i: -a -l help,release-user:,source-dir:,release-version: -n 'ERROR' -- "$@"`

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

       #-i|--srv-ip ) CTA_SRV_IP=$2
       #echo "cta srv is: $CTA_SRV_IP"
       #shift 2 ;;

        -- ) shift; break ;;
        * ) echo "$1 is not option" ; exit 1 ;;
	esac
done

#判断传入的参数是否正确
if [[ -z $SOURCE_DIR ]]; then
  usage
  exit 1
fi

if [[ -z $NEW_VERSION ]]; then
  usage
  exit 1
fi

cd $SOURCE_DIR
tar xf cta-$NEW_VERSION.tar.gz
cd ./cta_seg_release/build
bash ./build.sh
#docker image load -i cta-$NEW_VERSION.tar.gz
#docker tag storage-shshukun:5050/cta:$NEW_VERSION shukun/cta
docker images



