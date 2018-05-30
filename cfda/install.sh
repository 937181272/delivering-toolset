#!/usr/bin/env bash
set -e

__ScriptName="install.sh"

#-----------------------------------------------------------------------
# FUNCTION: usage
# DESCRIPTION:  Display usage information.
#-----------------------------------------------------------------------
usage() {
  cat << EOT
    Usage :  ${__ScriptName} [OPTION] ...
      install app from given options.

    Required Options:
      --help  display help message
      --mysql-password=MYSQL_PWD      mysql password
      --mysql-root-password=MYSQL_ROOT_PWD      mysql root password
      --mongo-password=MONGO_PWD      mongo password
      --srv-ip=CTA_SRV_IP      registry server pwd

      Exit status:
      0   if OK,
      !=0 if serious problems.

    Example:
      1) Use long options to install app:
        $ sudo $__ScriptName --mysql-password=test --mysql-root-password=test --mongo-password=test --srv-ip=192.168.1.1
EOT
}

APP_DIR=$(cd `dirname $0`/..; pwd)
cd $APP_DIR

DOCKER_REGISTRY_USER=devops1
RELEASE_SERVER_USER=devops1
DOCKER_REGISTRY_PWD=
RELEASE_SERVER_PWD=
MYSQL_PWD=
MONGO_PWD=
MYSQL_ROOT_PWD=
CTA_SRV_IP=

# parse options:
RET=`getopt -o hk:b:c:j -a -l help,mysql-password:,mysql-root-password:,mongo-password:,srv-ip: -n 'ERROR' -- "$@"`

if [ $? != 0 ] ; then echo "$__ScriptName exited with doing nothing." >&2 ; exit 1 ; fi

# Note the quotes around $RET: they are essential!
eval set -- "$RET"

# set option values
while true; do
    case "$1" in
       -h|--help ) usage; exit 1;;

       -k|--mysql-password ) MYSQL_PWD=$2
       echo "mysql password is: $MYSQL_PWD"
       shift 2 ;;

       -b|--mysql-root-password ) MYSQL_ROOT_PWD=$2
       echo "mysql root password is: $MYSQL_ROOT_PWD"
       shift 2 ;;

       -c|--mongo-password ) MONGO_PWD=$2
       echo "mongo password is: $MONGO_PWD"
       shift 2 ;;

       -j|--srv-ip ) CTA_SRV_IP=$2
       echo "cta srv is: $CTA_SRV_IP"
       shift 2 ;;

       -- ) shift; break ;;
       * ) echo "$1 is not option" ; exit 1 ;;
  esac
done

if [[ -z $MYSQL_PWD ]]; then
  usage
  exit 1
fi

if [[ -z $MONGO_PWD ]]; then
  usage
  exit 1
fi

if [[ -z $MYSQL_ROOT_PWD ]]; then
  usage
  exit 1
fi

if [[ -z $CTA_SRV_IP ]]; then
  usage
  exit 1
fi


DOCKER_CTA_VERSION=latest
DOCKER_DICOMER_VERSION=latest
DATA_DIR=/data0/rundata
WORKSPACE=/home/devops1/sk
MODEL_WORKSPACE=/var/lib/skmodel
CTA3D_DIR=$MODEL_WORKSPACE/cta3d/releases
NARROW_CLASS_DIR=$MODEL_WORKSPACE/cta_narrow_classification/releases
STRAIGHT_SEG_DIR=$MODEL_WORKSPACE/cta_straight_seg/releases
CTA2D_DIR=$MODEL_WORKSPACE/cta2d/releases
CTA_SRV=medicalbrain-cta-srv
CTA_CYPRESS=medicalbrain-cta-cypress

APP_FILE_UPLOAD_DIR=$DATA_DIR/cta_srv_cases
APP_DATA_INSTANCE_DIR=$DATA_DIR/cta_srv_output
APP_AW_DIR=$DATA_DIR/cta_srv_cases_aw

APP_MONGO_DATA_DIR=$WORKSPACE/data/mongo
APP_MYSQL_DATA_DIR=$WORKSPACE/data/mysql

LOGS_DIR=$DATA_DIR/logs
MEDICALBRAIN_CTA_S_CONFIG=$WORKSPACE/$CTA_SRV/configs/station.yml
LIB_DICOM_INTERFACE_CONFIG=$WORKSPACE/$CTA_SRV/configs/lib_dicom_config.yml
DELIVER_TOOLSET_DIR=$WORKSPACE/delivering-toolset

function waiting_port()
{
  echo "Waiting listen on $1 ..."
  while ! nc -z localhost $1; do
    sleep 0.1 # wait for 1/10 of the second before check again
  done
}

function cleanup_dir()
{
  target_dir=$1
  echo "> cleanup directory $target_dir ... "
  if [[ ! -d $target_dir ]]; then
    mkdir -p $target_dir
  else
    rm -rf $target_dir
    mkdir $target_dir
  fi
}

echo "> load docker image mongo ... "
docker load < mongo_image.tar.gz

echo "> load docker image mysql ... "
docker load < mysql_image.tar.gz

echo "> load docker image dicomer ... "
docker load < dicomer_image.tar.gz
docker tag storage-shshukun:5050/dicomer shukun/dicomer

echo "> build cta image ... "
tar -xvf cta_seg_release.tar.gz
cd cta_seg_release/build
./build.sh
cd $APP_DIR

echo '> cleanup model workspace'
cleanup_dir $MODEL_WORKSPACE

# cp model to destionation path
echo '> install model ... '
mkdir -p $CTA2D_DIR
tar -xzvf cta2d.tar.gz -C $CTA2D_DIR

mkdir -p $CTA3D_DIR
tar -xzvf cta3d.tar.gz -C $CTA3D_DIR

mkdir -p $NARROW_CLASS_DIR
tar -xzvf cta_narrow_classification.tar.gz -C $NARROW_CLASS_DIR

mkdir -p $STRAIGHT_SEG_DIR
tar -xzvf cta_straight_seg.tar.gz -C $STRAIGHT_SEG_DIR

echo '> create related dir for app ... '
if [[ ! -d $APP_FILE_UPLOAD_DIR ]]; then
  mkdir -p $APP_FILE_UPLOAD_DIR
fi

if [[ ! -d $APP_DATA_INSTANCE_DIR ]]; then
  mkdir -p $APP_DATA_INSTANCE_DIR
fi

if [[ ! -d $APP_AW_DIR ]]; then
  mkdir -p $APP_AW_DIR
fi

if [[ ! -d $LOGS_DIR ]]; then
  mkdir $LOGS_DIR
fi

if [[ ! -d $APP_MONGO_DATA_DIR ]]; then
  mkdir -p $APP_MONGO_DATA_DIR
fi

if [[ ! -d $APP_MYSQL_DATA_DIR ]]; then
  mkdir -p $APP_MYSQL_DATA_DIR
fi

echo '> cleanup workspace ...'
cleanup_dir $WORKSPACE

tar -xzvf $CTA_SRV.tar.gz -C $WORKSPACE

echo "> install dependencies ... "
tar -zxvf python_lib.tar.gz
pip install --no-index --find-links=./python_lib/packages -r $WORKSPACE/$CTA_SRV/requirements.txt
pip install --no-index --find-links=./python_lib/packages -r $WORKSPACE/$CTA_SRV/requirements_local.txt

echo '> create initial config files ...'
cp $MEDICALBRAIN_CTA_S_CONFIG.sample $MEDICALBRAIN_CTA_S_CONFIG
cp $LIB_DICOM_INTERFACE_CONFIG.sample $LIB_DICOM_INTERFACE_CONFIG

echo '> start mysql and mongo container and config'
docker stop cta-mysql && docker rm cta-mysql
docker run --restart=always --name cta-mysql -p 5506:3306 -e MYSQL_DATABASE=cta -e MYSQL_USER=shukun -e MYSQL_PASSWORD=$MYSQL_PWD -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PWD -e TZ=Asia/Shanghai -v $APP_MYSQL_DATA_DIR:/var/lib/mysql -d storage-shshukun:5050/mysql:latest --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci --max-allowed-packet=33554432
docker stop cta-mongo && docker rm cta-mongo
docker run --restart=always --name cta-mongo -p 27017:27017  -v $APP_MONGO_DATA_DIR:/data/db -e MONGODB_DATABASE=cta -e MONGODB_USER=cta_user -e MONGODB_PASS=$MONGO_PWD -d storage-shshukun:5050/mongo:latest

waiting_port 27017
waiting_port 5506

echo 'waiting for db startup ...'
sleep 30

echo '> update mongo config ...'
sed -i '/MONGO_URI/'d $MEDICALBRAIN_CTA_S_CONFIG
echo -e "\nMONGO_URI: \"mongodb://cta_user:$MONGO_PWD@localhost:27017/cta\"" >> $MEDICALBRAIN_CTA_S_CONFIG

echo '> update mysql config ...'
sed -i '/SQLALCHEMY_DATABASE_URI/'d $MEDICALBRAIN_CTA_S_CONFIG
echo -e "\nSQLALCHEMY_DATABASE_URI: \"mysql+pymysql://shukun:$MYSQL_PWD@localhost:5506/cta?charset=utf8mb4\"" >> $MEDICALBRAIN_CTA_S_CONFIG

echo '> update output folder ...'
sed -i '/storage_folder/'d $LIB_DICOM_INTERFACE_CONFIG
echo -e "\n  storage_folder: \"$APP_AW_DIR\"" >> $LIB_DICOM_INTERFACE_CONFIG

echo '> start app db init ...'
#$WORKSPACE/$CTA_SRV/bin/start_build.sh

echo '> start app ...'
#$WORKSPACE/$CTA_SRV/bin/start_app.sh all

export BASE_URL="http://$CTA_SRV_IP:5000"
export DOCTOR_URL="http://$CTA_SRV_IP:76"
export POSTPROC_URL="http://$CTA_SRV_IP:75"

echo "> install $CTA_CYPRESS ..."
tar -xzvf $CTA_CYPRESS.tar.gz -C $WORKSPACE
cd $WORKSPACE/$CTA_CYPRESS
./install.sh

#TODO create soft link ln -s /Users/apple/sk/cta-data /Users/apple/sk/medicalbrain-cta-botree/files
ln -s $APP_DATA_INSTANCE_DIR $WORKSPACE/$CTA_CYPRESS/files

echo '> config nginx ...'
cd $APP_DIR/delivering-toolset
sed -i "s#cypress_home_dir#$WORKSPACE/$CTA_CYPRESS#g" nginx-cypress.conf

cp nginx-cypress.conf /etc/nginx/conf.d/

nginx -t
/etc/init.d/nginx reload

cp ../CoronaryGo.desktop /usr/share/applications/
echo '> app install successfully, pls check the config files and start backend app.'
