#!/bin/bash
set -e

__ScriptName="update_cta.sh"

#-----------------------------------------------------------------------  
# FUNCTION: usage  
# DESCRIPTION:  Display usage information.  
#-----------------------------------------------------------------------  
usage() {
  cat << EOT
    Usage :  ${__ScriptName} [OPTION] ...
      update app from given options.
      
    Required Options:  
      --help                  display help message
      --release-password=RELEASE_SERVER_PWD     release server pwd
      --release-version=NEW_VERSION       new version,eg:0.0.2
      --prod-id=PROD_ID

      Exit status:
      0   if OK,
      !=0 if serious problems.
      
    Example:
      1) Use long options to build app:
        $ sudo $__ScriptName --release-password=test --release-version=0.0.2 --prod-id=zdyfy-001
EOT
}

APP_NAME=cta
RELEASE_SERVER_USER=devops1
RELEASE_SERVER_PWD=
NEW_VERSION=
PROD_ID=

# parse options:  
RET=`getopt -o hp:v:j: -a -l help,release-password:,release-version:,prod-id: -n 'ERROR' -- "$@"`

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

if [[ -z $PROD_ID ]]; then
  usage
  exit 1
fi

docker login -u devops1 -p $RELEASE_SERVER_PWD storage-shshukun:5050
docker pull storage-shshukun:5050/cta:$NEW_VERSION
docker tag storage-shshukun:5050/cta:$NEW_VERSION shukun/cta
docker images

echo "add ops center update record"
curl -l -H "Content-type: application/json" -H "token: shukun111222" -X POST -d "{\"workStation\":{\"name\":\"$PROD_ID\"},\"appVersion\":{\"name\":\"$APP_NAME\", \"version\":\"$NEW_VERSION\"}}" http://103.211.47.132:9092/api/v1/workstationupdates

