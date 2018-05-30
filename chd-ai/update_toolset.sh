#!/bin/bash
set -e

__ScriptName="update_toolset.sh"

#-----------------------------------------------------------------------  
# FUNCTION: usage  
# DESCRIPTION:  Display usage information.  
#-----------------------------------------------------------------------  
usage() {
  cat << EOT
    Usage :  ${__ScriptName} [OPTION] ...
      Build app from given options.
      
    Options:  
      --help									display help message
      --release-user=RELEASE_SERVER_USER        release server user
      --release-password=RELEASE_SERVER_PWD    	release server pwd
      --release-version=NEW_VERSION				new version,eg:0.0.2
      --prod-id=PROD_ID

      Exit status:
      0   if OK,
      !=0 if serious problems.
      
    Example:
      1) Use long options to build app:
        $ sudo $__ScriptName --release-user=test --release-password=test --release-version=0.0.2 --prod-id=zdyfy-001
EOT
}

APP_DIR=/home/devops1/sk
APP_NAME=delivering-toolset
RELEASE_SERVER_USER=
RELEASE_SERVER_PWD=
NEW_VERSION=
PROD_ID=

# parse options:  
RET=`getopt -o hu:p:v:j -a -l help,release-user:,release-password:,release-version:,prod-id: -n 'ERROR' -- "$@"`

if [ $? != 0 ] ; then echo "$__ScriptName exited with doing nothing." >&2 ; exit 1 ; fi

# Note the quotes around $RET: they are essential!
eval set -- "$RET"

# set option values
while true; do
    case "$1" in
        -h|--help ) usage; exit 1;;

        -u|--release-user ) RELEASE_SERVER_USER=$2
       echo " > usename is: $RELEASE_SERVER_USER"
       shift 2 ;;

        -p|--release-password ) RELEASE_SERVER_PWD=$2
       shift 2 ;;

        -v|--release-version ) NEW_VERSION=$2
       echo " > new version is: $NEW_VERSION"
       shift 2 ;;

        -j|--prod-id ) PROD_ID=$2
       echo "cta srv is: $PROD_ID"
       shift 2 ;;

        -- ) shift; break ;;
        * ) echo " > $1 is not option" ; exit 1 ;;
	esac
done

cd $APP_DIR

echo " > download $NEW_VERSION cypress"
rm -rf $APP_NAME-$NEW_VERSION.tar.gz
wget --http-user=$RELEASE_SERVER_USER --http-password=$RELEASE_SERVER_PWD http://103.211.47.132:99/$APP_NAME/$NEW_VERSION/$APP_NAME-$NEW_VERSION.tar.gz

#echo pre_version=$(cat ./$APP_NAME/.version)
echo " > backup previous version $pre_version"
rm -rf $APP_NAME.bak
mv $APP_NAME $APP_NAME.bak

echo " > unzip app $APP_NAME"
tar -xzvf $APP_NAME-$NEW_VERSION.tar.gz

#TODO check if frontend is started up
echo " > rm tar package "
rm -rf $APP_NAME-$NEW_VERSION.tar.gz

echo '*************************'
echo 'the updated version is : '
cat $APP_NAME/VERSION
echo '*************************'

echo "add ops center update record"
curl -l -H "Content-type: application/json" -H "token: shukun111222" -X POST -d "{\"workStation\":{\"name\":\"$PROD_ID\"},\"appVersion\":{\"name\":\"$APP_NAME\", \"version\":\"$NEW_VERSION\"}}" http://103.211.47.132:9092/api/v1/workstationupdates

