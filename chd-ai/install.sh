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
      --help	display help message
      --mysql-password=MYSQL_PWD      mysql password
      --mysql-root-password=MYSQL_ROOT_PWD      mysql root password
      --mongo-password=MONGO_PWD      mongo password				
      --release-password=RELEASE_SERVER_PWD    	release server pwd
      --registry-password=RELEASE_SERVER_PWD    	registry server pwd
      --srv-version=CTA_SRV_VERSION				new version,eg:0.0.2
      --daphne-version=CTA_DAPHNE_VERSION				new version,eg:0.0.2
      --cypress-version=CTA_CYPRESS_VERSION				new version,eg:0.0.2

      Exit status:
      0   if OK,
      !=0 if serious problems.
      
    Example:
      1) Use long options to install app:
        $ sudo $__ScriptName --mysql-password=test --mysql-root-password=test --mongo-password=test --release-password=test --registry-password=test --srv-version=0.0.2 --daphne-version=0.0.2 --cypress-version=0.0.2 --srv-ip=192.168.1.1 --cta2d-version=0.0.2 --cta3d-version=0.0.2 --cta-narrow-class-version=0.0.2 --cta-straight-seg-version=0.0.2
EOT
}

DOCKER_REGISTRY_USER=devops1
RELEASE_SERVER_USER=devops1
DOCKER_REGISTRY_PWD=
RELEASE_SERVER_PWD=
MYSQL_PWD=
MONGO_PWD=
MYSQL_ROOT_PWD=
CTA_SRV_VERSION=
CTA_DAPHNE_VERSION=
CTA_CYPRESS_VERSION=
CTA_SRV_IP=
CTA3D_VERSION=
CTA2D_VERSION=
NARROW_CLASS_VERSION=
STRAIGHT_SEG_VERSION=

# parse options:  
RET=`getopt -o hk:b:c:d:e:f:g:i:j:k:l:m:n -a -l help,mysql-password:,mysql-root-password:,mongo-password:,release-password:,registry-password:,srv-version:,daphne-version:,cypress-version:,srv-ip:,cta3d-version:,cta2d-version:,cta-narrow-class-version:,cta-straight-seg-version: -n 'ERROR' -- "$@"`

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

       -d|--release-password ) RELEASE_SERVER_PWD=$2
	   echo "release pwd is: $RELEASE_SERVER_PWD"
       shift 2 ;;

       -e|--registry-password ) DOCKER_REGISTRY_PWD=$2
	   echo "registry pwd is: $DOCKER_REGISTRY_PWD"
       shift 2 ;;

       -f|--srv-version ) CTA_SRV_VERSION=$2
       echo "srv version is: $CTA_SRV_VERSION"
       shift 2 ;;

       -g|--daphne-version ) CTA_DAPHNE_VERSION=$2
       echo "daphne version is: $CTA_DAPHNE_VERSION"
       shift 2 ;;

       -i|--cypress-version ) CTA_CYPRESS_VERSION=$2
       echo "cypress version is: $CTA_CYPRESS_VERSION"
       shift 2 ;;

       -j|--srv-ip ) CTA_SRV_IP=$2
       echo "cta srv is: $CTA_SRV_IP"
       shift 2 ;;

       -k|--cta3d-version ) CTA3D_VERSION=$2
       echo "cta3d version is: $CTA3D_VERSION"
       shift 2 ;;

        -l|--cta-narrow-class-version ) NARROW_CLASS_VERSION=$2
       echo "cta-narrow-class version is: $NARROW_CLASS_VERSION"
       shift 2 ;;

       -m|--cta-straight-seg-version ) STRAIGHT_SEG_VERSION=$2
       echo "cta-straight-seg version is: $STRAIGHT_SEG_VERSION"
       shift 2 ;;

       -n|--cta2d-version ) CTA2D_VERSION=$2
       echo "cta2d version is: $CTA2D_VERSION"
       shift 2 ;;

        -- ) shift; break ;;
        * ) echo "$1 is not option" ; exit 1 ;;
	esac
done

if [[ -z $DOCKER_REGISTRY_PWD ]]; then
	usage
	exit 1
fi

if [[ -z $RELEASE_SERVER_PWD ]]; then
	usage
	exit 1
fi

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

if [[ -z $CTA_SRV_VERSION ]]; then
	usage
	exit 1
fi

if [[ -z $CTA_DAPHNE_VERSION ]]; then
	usage
	exit 1
fi

if [[ -z $CTA_CYPRESS_VERSION ]]; then
	usage
	exit 1
fi

if [[ -z $CTA_SRV_IP ]]; then
	usage
	exit 1
fi

if [[ -z $CTA2D_VERSION ]]; then
  usage
  exit 1
fi

if [[ -z $CTA3D_VERSION ]]; then
  usage
  exit 1
fi

if [[ -z $NARROW_CLASS_VERSION ]]; then
  usage
  exit 1
fi

if [[ -z $STRAIGHT_SEG_VERSION ]]; then
  usage
  exit 1
fi

DOCKER_CTA_VERSION=latest
DOCKER_DICOMER_VERSION=latest
DATA_DIR=/data0/rundata
WORKSPACE=/home/devops1/sk
CTA_SRV=medicalbrain-cta-srv
CTA_DAPHNE=medicalbrain-cta-daphne
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

echo '> config aliyun source list'
DATE=`date +%Y%m%d%H%M%S`
mv /etc/apt/sources.list /etc/apt/sources.list.$DATE.bak
cp $DELIVER_TOOLSET_DIR/common/aliyun_sources.list /etc/apt/sources.list

echo '> update system ...'
apt-get update -y

# TODO check if git is installed
# TODO check if cuda is installed
# TODO check if nvidia driver

echo '> install and config docker ...'
$DELIVER_TOOLSET_DIR/common/install_docker.sh
# service docker status
sed -i '/registry-mirrors/'d /etc/docker/daemon.json
sed -i '2i"registry-mirrors": ["https://wwuqa7no.mirror.aliyuncs.com"],' /etc/docker/daemon.json
sed -i '/insecure-registries/'d /etc/docker/daemon.json
sed -i '2i"insecure-registries" : ["storage-shshukun:5050"],' /etc/docker/daemon.json
cat /etc/docker/daemon.json
# TODO stop all running docker container
service docker restart

# echo '> install nodejs nvm and nodejs 8.4.0 ...'
# curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash
# source ~/.bashrc
# nvm install 8.4.0

echo '> install nginx ...'
apt-get install nginx -y
# service nginx status

echo '> install pip ...'
apt install python-pip -y
pip install --upgrade pip -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com

echo '> add private docker registry ...'
sed -i '/storage-shshukun/'d /etc/hosts
sed -i "1i103.211.47.132 storage-shshukun" /etc/hosts

echo '> pull mongo and mysql docker image ...'
docker login -u $DOCKER_REGISTRY_USER -p $DOCKER_REGISTRY_PWD storage-shshukun:5050
docker pull storage-shshukun:5050/mongo:latest
docker pull storage-shshukun:5050/mysql:latest

echo '> pull cta and dicomer docker image ...'
docker pull storage-shshukun:5050/cta:$DOCKER_CTA_VERSION
docker pull storage-shshukun:5050/dicomer:$DOCKER_DICOMER_VERSION
docker tag storage-shshukun:5050/cta:$DOCKER_CTA_VERSION shukun/cta:$DOCKER_CTA_VERSION
docker tag storage-shshukun:5050/dicomer:$DOCKER_DICOMER_VERSION shukun/dicomer:$DOCKER_DICOMER_VERSION

echo '> pull model'
./update_model.sh --release-password=$RELEASE_SERVER_PWD --cta2d-version=$CTA2D_VERSION --cta3d-version=$CTA3D_VERSION --cta-narrow-class-version=$NARROW_CLASS_VERSION --cta-straight-seg-version=$STRAIGHT_SEG_VERSION

if [[ ! -d $APP_FILE_UPLOAD_DIR ]]; then
	mkdir -p $APP_FILE_UPLOAD_DIR
fi

if [[ ! -d $APP_DATA_INSTANCE_DIR ]]; then
	mkdir -p $APP_DATA_INSTANCE_DIR
fi

if [[ ! -d $APP_AW_DIR ]]; then
	mkdir -p $APP_AW_DIR
fi

if [[ ! -d $APP_MONGO_DATA_DIR ]]; then
	mkdir -p $APP_MONGO_DATA_DIR
fi

if [[ ! -d $APP_MYSQL_DATA_DIR ]]; then
	mkdir -p $APP_MYSQL_DATA_DIR
fi

cd $WORKSPACE

echo '> cleanup workspace'
rm -rf $CTA_SRV-$CTA_SRV_VERSION
rm -rf $CTA_DAPHNE-$CTA_DAPHNE_VERSION
rm -rf $CTA_CYPRESS-$CTA_CYPRESS_VERSION
rm -rf $CTA_SRV-$CTA_SRV_VERSION.tar.gz
rm -rf $CTA_DAPHNE-$CTA_DAPHNE_VERSION.tar.gz
rm -rf $CTA_CYPRESS-$CTA_CYPRESS_VERSION.tar.gz

echo '> install medicalbrain-cta-srv ...'
wget --http-user=$RELEASE_SERVER_USER --http-password=$RELEASE_SERVER_PWD http://103.211.47.132:99/$CTA_SRV/$CTA_SRV_VERSION/$CTA_SRV-$CTA_SRV_VERSION.tar.gz
tar -xzvf $CTA_SRV-$CTA_SRV_VERSION.tar.gz
cd $CTA_SRV

echo '> create initial config files ...'
cp $MEDICALBRAIN_CTA_S_CONFIG.sample $MEDICALBRAIN_CTA_S_CONFIG
cp $LIB_DICOM_INTERFACE_CONFIG.sample $LIB_DICOM_INTERFACE_CONFIG


echo '> install medicalbrain-cta-srv dependences ...'
pip install -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com -r requirements.txt
pip install -i http://103.211.47.132:3141/simple --trusted-host 103.211.47.132 -r requirements_local.txt

echo '> update config file ...'
sed -i '/UPLOAD_FOLDER/'d $MEDICALBRAIN_CTA_S_CONFIG
sed -i '/DATA_INSTANCE_FOLDER/'d $MEDICALBRAIN_CTA_S_CONFIG
echo -e "\nUPLOAD_FOLDER: \"$APP_FILE_UPLOAD_DIR\"" >> $MEDICALBRAIN_CTA_S_CONFIG
echo -e "\nDATA_INSTANCE_FOLDER: \"$APP_DATA_INSTANCE_DIR\"" >> $MEDICALBRAIN_CTA_S_CONFIG

echo '> start mysql and mongo container and config'
docker stop cta-mysql && docker rm cta-mysql
docker run --restart=always --name cta-mysql -p 5506:3306 -e MYSQL_DATABASE=cta -e MYSQL_USER=shukun -e MYSQL_PASSWORD=$MYSQL_PWD -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PWD -e TZ=Asia/Shanghai -v $APP_MYSQL_DATA_DIR:/var/lib/mysql -d storage-shshukun:5050/mysql:latest --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci --max-allowed-packet=33554432
docker stop cta-mongo && docker rm cta-mongo
docker run --restart=always --name cta-mongo -p 27017:27017  -v $APP_MONGO_DATA_DIR:/data/db -e MONGODB_DATABASE=cta -e MONGODB_USER=cta_user -e MONGODB_PASS=$MONGO_PWD -d storage-shshukun:5050/mongo:latest

waiting_port 27017
waiting_port 5506

echo 'waiting for app startup ...'
sleep 45

echo '> update mongo config ...'
sed -i '/MONGO_URI/'d $MEDICALBRAIN_CTA_S_CONFIG
echo -e "\nMONGO_URI: \"mongodb://cta_user:$MONGO_PWD@localhost:27017/cta\"" >> $MEDICALBRAIN_CTA_S_CONFIG

echo '> update mysql config ...'
sed -i '/SQLALCHEMY_DATABASE_URI/'d $MEDICALBRAIN_CTA_S_CONFIG
echo -e "\nSQLALCHEMY_DATABASE_URI: \"mysql+pymysql://shukun:$MYSQL_PWD@localhost:5506/cta?charset=utf8mb4\"" >> $MEDICALBRAIN_CTA_S_CONFIG

echo '> update output folder ...'
sed -i '/storage_folder/'d $LIB_DICOM_INTERFACE_CONFIG
echo -e "\n  storage_folder: \"$APP_AW_DIR\"" >> $LIB_DICOM_INTERFACE_CONFIG

echo '> create log dir'
if [[ ! -d $LOGS_DIR ]]; then
	mkdir $LOGS_DIR
fi

chmod 775 ./bin/*.sh
echo '> start app data init ...'
./bin/start_build.sh

# echo '> start app ...'
# ./bin/start_app.sh all $LOGS_DIR

export BASE_URL="http://$CTA_SRV_IP:5000"
export DOCTOR_URL="http://$CTA_SRV_IP:76"
export POSTPROC_URL="http://$CTA_SRV_IP:75"

echo "> install $CTA_DAPHNE ..."
cd $WORKSPACE
wget --http-user=$RELEASE_SERVER_USER --http-password=$RELEASE_SERVER_PWD http://103.211.47.132:99/$CTA_DAPHNE/$CTA_DAPHNE_VERSION/$CTA_DAPHNE-$CTA_DAPHNE_VERSION.tar.gz
tar -xzvf $CTA_DAPHNE-$CTA_DAPHNE_VERSION.tar.gz
cd $WORKSPACE/$CTA_DAPHNE
./install.sh

echo "> install $CTA_CYPRESS ..."
cd $WORKSPACE
wget --http-user=$RELEASE_SERVER_USER --http-password=$RELEASE_SERVER_PWD http://103.211.47.132:99/$CTA_CYPRESS/$CTA_CYPRESS_VERSION/$APP_LEVEL-$CTA_CYPRESS-$CTA_CYPRESS_VERSION.tar.gz
tar -xzvf $APP_LEVEL-$CTA_CYPRESS-$CTA_CYPRESS_VERSION.tar.gz
cd $WORKSPACE/$CTA_CYPRESS
./install.sh

echo "> create soft link ..."
cd $WORKSPACE
ln -s $APP_DATA_INSTANCE_DIR $CTA_DAPHNE/files
ln -s $APP_DATA_INSTANCE_DIR $CTA_CYPRESS/files

echo '> config nginx ...'
sed -i "s#daphne_home_dir#$WORKSPACE/$CTA_DAPHNE#g" $DELIVER_TOOLSET_DIR/nginx-conf/nginx-daphne.conf
sed -i "s#cypress_home_dir#$WORKSPACE/$CTA_CYPRESS#g" $DELIVER_TOOLSET_DIR/nginx-conf/nginx-cypress.conf

cp $DELIVER_TOOLSET_DIR/nginx-conf/nginx-daphne.conf /etc/nginx/conf.d/
cp $DELIVER_TOOLSET_DIR/nginx-conf/nginx-cypress.conf /etc/nginx/conf.d/

nginx -t
/etc/init.d/nginx reload

echo '> remove tar package'
rm -rf $CTA_SRV-$CTA_SRV_VERSION.tar.gz
rm -rf $CTA_DAPHNE-$CTA_DAPHNE_VERSION.tar.gz
rm -rf $CTA_CYPRESS-$CTA_CYPRESS_VERSION.tar.gz

echo '> app install successfully, pls check the config files and start backend app.'






