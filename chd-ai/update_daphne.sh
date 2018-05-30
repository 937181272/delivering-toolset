#!/bin/bash
set -e

__ScriptName="update_daphne.sh"

#-----------------------------------------------------------------------  
# FUNCTION: usage  
# DESCRIPTION:  Display usage information.  
#-----------------------------------------------------------------------  
usage() {
  cat << EOT
    Usage :  ${__ScriptName} [OPTION] ...
      Build app from given options.
      
    Required Options:  
      --help                  display help message
      --release-password=RELEASE_SERVER_PWD     release server pwd
      --release-version=NEW_VERSION       new version,eg:0.0.2
      --srv-ip=CTA_SRV_IP                 srv ip
      --app-level=APP_LEVEL                 app level
      --prod-id=PROD_ID

      Exit status:
      0   if OK,
      !=0 if serious problems.
      
    Example:
      1) Use long options to build app:
        $ sudo $__ScriptName --release-user=test --release-password=test --release-version=0.0.2 --srv-ip=192.168.1.1 --app-level=standard --prod-id=zdyfy-001
EOT
}

WORKSPACE=/home/devops1/sk
APP_NAME=medicalbrain-cta-daphne
RELEASE_SERVER_USER=devops1
RELEASE_SERVER_PWD=
NEW_VERSION=
CTA_SRV_IP=
APP_LEVEL=
PROD_ID=

# parse options:  
RET=`getopt -o hp:v:i:l:j: -a -l help,release-password:,release-version:,srv-ip:,app-level:,prod-id: -n 'ERROR' -- "$@"`

if [ $? != 0 ] ; then echo "$__ScriptName exited with doing nothing." >&2 ; exit 1 ; fi

# Note the quotes around $RET: they are essential!
eval set -- "$RET"

# set option values
while true; do
    case "$1" in
        -h|--help ) usage; exit 1;;

        -p|--release-password ) RELEASE_SERVER_PWD=$2
       shift 2 ;;

        -v|--release-version ) NEW_VERSION=$2
       echo "new version is: $NEW_VERSION"
       shift 2 ;;

       -i|--srv-ip ) CTA_SRV_IP=$2
       echo "cta srv is: $CTA_SRV_IP"
       shift 2 ;;

       -l|--app-level ) APP_LEVEL=$2
       echo "cta srv is: $APP_LEVEL"
       shift 2 ;;

       -j|--prod-id ) PROD_ID=$2
       echo "cta srv is: $PROD_ID"
       shift 2 ;;

        -- ) shift; break ;;
        * ) echo "$1 is not option" ; exit 1 ;;
  esac
done

if [[ -z $RELEASE_SERVER_PWD ]]; then
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

if [[ -z $APP_LEVEL ]]; then
  usage
  exit 1
fi

if [[ -z $PROD_ID ]]; then
  usage
  exit 1
fi

cd $WORKSPACE

echo " > download $NEW_VERSION cypress"
rm -rf $APP_LEVEL-$APP_NAME-$NEW_VERSION.tar.gz
wget --http-user=$RELEASE_SERVER_USER --http-password=$RELEASE_SERVER_PWD http://103.211.47.132:99/$APP_NAME/$NEW_VERSION/$APP_LEVEL-$APP_NAME-$NEW_VERSION.tar.gz

#echo pre_version=$(cat ./$APP_NAME/.version)
echo " > backup previous version $pre_version"
rm -rf $APP_NAME.bak
if [[ -d $APP_NAME ]]; then
  mv $APP_NAME $APP_NAME.bak
fi

echo " > unzip app $APP_NAME"
tar -xzvf $APP_LEVEL-$APP_NAME-$NEW_VERSION.tar.gz

echo ' > create soft link'
ln -s /data0/rundata/cta_srv_output/ $WORKSPACE/$APP_NAME/files

#TODO check if frontend is started up
echo " > rm tar package "
cd ..
rm -rf $APP_LEVEL-$APP_NAME-$NEW_VERSION.tar.gz

echo '*************************'
echo 'the updated version is : '
cat $APP_NAME/VERSION
echo '*************************'

echo "add ops center update record"
curl -l -H "Content-type: application/json" -H "token: shukun111222" -X POST -d "{\"workStation\":{\"name\":\"$PROD_ID\"},\"appVersion\":{\"name\":\"$APP_NAME\", \"appLevel\":\"$APP_LEVEL\", \"version\":\"$NEW_VERSION\"}}" http://103.211.47.132:9092/api/v1/workstationupdates

