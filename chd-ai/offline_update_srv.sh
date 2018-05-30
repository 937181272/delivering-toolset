#!/bin/bash
set -e

__ScriptName="offline_update_srv.sh"

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
      --start-app=START_APP                 start app
      --backup-mysql=BACKUP_MYSQL           backup mysql
      --prod-id=PROD_ID

      Exit status:
      0   if OK,
      !=0 if serious problems.
      
    Example:
      1) Use long options to build app:
        $ sudo $__ScriptName --release-password=test --release-version=0.0.2 --start-app=false --backup-mysql=false --prod-id=whzxyy-001
EOT
}


WORKSPACE=/home/devops1/sk
APP_NAME=medicalbrain-cta-srv
RELEASE_SERVER_USER=devops1
RELEASE_SERVER_PWD=
NEW_VERSION=
START_APP=
PROD_ID=
BACKUP_MYSQL=

# parse options:  
RET=`getopt -o hp:v:i:l:j: -a -l help,release-password:,release-version:,start-app:,backup-mysql:,prod-id: -n 'ERROR' -- "$@"`

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

       -i|--start-app ) START_APP=$2
       echo "start app is: $START_APP"
       shift 2 ;;

       -l|--backup-mysql ) BACKUP_MYSQL=$2
       echo "backup mysql is: $BACKUP_MYSQL"
       shift 2 ;;

       -j|--prod-id ) PROD_ID=$2
       echo "prod id is: $PROD_ID"
       shift 2 ;;

        -- ) shift; break ;;
        * ) echo "$1 is not option" ; exit 1 ;;
  esac
done


echo '> stop app ...'
if [[ -d $WORKSPACE/$APP_NAME ]]; then
	chmod u+x $WORKSPACE/$APP_NAME/bin/*.sh
fi
$WORKSPACE/$APP_NAME/bin/stop_app.sh all

cd $WORKSPACE/delivering-toolset/chd-ai

if [[ $BACKUP_MYSQL == "true" ]]; then
  ./backup_mysql.sh shukun skdev0ps! cta $PROD_ID
fi

# 备份当前的应用，移到备份目录
echo '> backup current app ...'
if [[ -d $WORKSPACE/$APP_NAME.bak ]]; then
	rm -rf $WORKSPACE/$APP_NAME.bak
fi
mv $WORKSPACE/$APP_NAME $WORKSPACE/$APP_NAME.bak

# 下载最新的代码，解压
cd $WORKSPACE
echo '> update medicalbrain-cta-srv ...'
#wget --http-user=$RELEASE_SERVER_USER --http-password=$RELEASE_SERVER_PWD http://103.211.47.132:99/$APP_NAME/$NEW_VERSION/$APP_NAME-$NEW_VERSION.tar.gz
cp $SOURCE_DIR/$APP_NAME-$NEW_VERSION.tar.gz .
tar -xf $APP_NAME-$NEW_VERSION.tar.gz


echo '> backup configs'
#cp -r $APP_NAME.bak/configs /data0/rundata/

echo '> cp config files ...'
cp $APP_NAME.bak/configs/station.yml $APP_NAME/configs/
cp $APP_NAME.bak/configs/lib_dicom_config.yml $APP_NAME/configs/

cd $APP_NAME

echo '> install medicalbrain-cta-srv dependences ...'
#tar -zxvf python_lib.tar.gz
#pip install --no-index --find-links=./python_lib/packages -r $WORKSPACE/$CTA_SRV/requirements.txt
#pip install --no-index --find-links=./python_lib/packages -r $WORKSPACE/$CTA_SRV/requirements_local.txt

echo '> migrate data ...'
./bin/start_migrate.sh

if [[ $START_APP == "true" ]]; then
	echo '> start app ...'
	./bin/start_app.sh all
fi

echo 'remove tar.gz file'
cd ..
rm -rf $APP_NAME-$NEW_VERSION.tar.gz

echo '*************************'
echo 'the updated version is : '
cat $APP_NAME/VERSION
echo '*************************'

