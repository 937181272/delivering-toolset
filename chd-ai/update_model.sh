#!/bin/bash
set -e

__ScriptName="update_model.sh"

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
      --release-password=RELEASE_SERVER_PWD    	release server pwd
      --cta3d-version=CTA3D_VERSION    	cta3d version
      --cta-narrow-class-version=NARROW_CLASS_VERSION				narrow class version
      --cta-straight-seg-version=STRAIGHT_SEG_VERSION               straight seg version
	    --cta2d-version=CTA2D_VERSION    	cta2d version
      --cta-myocardium-version=CTA_MYOCARDIUM_VERSION   myocardium version
      --cta_straight_qualifier=CTA_STRAIGHT_QUALIFIER     cta_straight_qualifier version
      --cta_denoise=CTA_DENOISE   cta_denoise version
      --prod-id=PROD_ID

      Exit status:
      0   if OK,
      !=0 if serious problems.
      
    Example:
      1) Use long options to build app:
        $ sudo $__ScriptName --release-password=test --cta2d-version=0.0.2 --cta3d-version=0.0.2 --cta-narrow-class-version=0.0.2 --cta-straight-seg-version=0.0.2 --cta-myocardium-version=0.0.2 --cta-straight-qualifier-version=0.1.0 --cta-denoise-version=0.1.0 --prod-id=zdyfy-001
EOT
}

MODEL_WORKSPACE=/var/lib/skmodel
CTA3D_DIR=$MODEL_WORKSPACE/cta3d/releases
NARROW_CLASS_DIR=$MODEL_WORKSPACE/cta_narrow_classification/releases
STRAIGHT_SEG_DIR=$MODEL_WORKSPACE/cta_straight_seg/releases
CTA2D_DIR=$MODEL_WORKSPACE/cta2d/releases
CTA_MYOCARDIUM_DIR=$MODEL_WORKSPACE/cta_myocardium/releases
CTA_STRAIGHT_QUALIFIER_DIR=$MODEL_WORKSPACE/cta_straight_qualifier/releases
CTA_DENOISE_DIR=$MODEL_WORKSPACE/cta_denoise/releases
CTA_CPR_CHECKER_DIR=$MODEL_WORKSPACE/cta_cpr_checker/releases
RELEASE_SERVER_USER=devops1
RELEASE_SERVER_PWD=
CTA3D_VERSION=
CTA2D_VERSION=
NARROW_CLASS_VERSION=
STRAIGHT_SEG_VERSION=
CTA_MYOCARDIUM_VERSION=
CTA_STRAIGHT_QUALIFIER_VERSION=
CTA_DENOISE_VERSION=
CTA_CPR_CHECKER_VERSION=
PROD_ID=


# parse options:  
RET=`getopt -o hp:c:d:e:f:g:i:j:k:m: -a -l help,release-password:,cta3d-version:,cta2d-version:,cta-narrow-class-version:,cta-straight-seg-version:,cta-myocardium-version:,cta-straight-qualifier-version:,cta-denoise-version:,prod-id:,cta-cpr-checker-version: -n 'ERROR' -- "$@"`

if [ $? != 0 ] ; then echo "$-_ScriptName exited with doing nothing." >&2 ; exit 1 ; fi

# Note the quotes around $RET: they are essential!
eval set -- "$RET"

# set option values
while true; do
    case "$1" in
        -h|--help ) usage; exit 1;;

        -p|--release-password ) RELEASE_SERVER_PWD=$2
       shift 2 ;;

        -c|--cta3d-version ) CTA3D_VERSION=$2
       echo "cta3d version is: $CTA3D_VERSION"
       shift 2 ;;

        -d|--cta-narrow-class-version ) NARROW_CLASS_VERSION=$2
       echo "cta-narrow-class version is: $NARROW_CLASS_VERSION"
       shift 2 ;;

       -e|--cta-straight-seg-version ) STRAIGHT_SEG_VERSION=$2
       echo "cta-straight-seg version is: $STRAIGHT_SEG_VERSION"
       shift 2 ;;

       -f|--cta2d-version ) CTA2D_VERSION=$2
       echo "cta2d version is: $CTA2D_VERSION"
       shift 2 ;;

       -g|--cta-myocardium-version ) CTA_MYOCARDIUM_VERSION=$2
       echo "myocardium version is: $CTA_MYOCARDIUM_VERSION"
       shift 2 ;;

       -i|--cta-straight-qualifier-version ) CTA_STRAIGHT_QUALIFIER_VERSION=$2
       echo "cta straight qualifier version is: $CTA_STRAIGHT_QUALIFIER_VERSION"
       shift 2 ;;

       -j|--cta-denoise-version ) CTA_DENOISE_VERSION=$2
       echo "cta denoise version is: $CTA_DENOISE_VERSION"
       shift 2 ;;

       -k|--prod-id ) PROD_ID=$2
       echo "cta srv is: $PROD_ID"
       shift 2 ;;

       -m|--cta-cpr-checker-version ) CTA_CPR_CHECKER_VERSION=$2
       echo "cta cpr checker version is: $CTA_CPR_CHECKER_VERSION"
       shift 2 ;;

        -- ) shift; break ;;
        * ) echo "$1 is not option" ; exit 1 ;;
	esac
done


if [[ ! -d $CTA3D_DIR ]]; then
	mkdir -p $CTA3D_DIR
fi

if [[ ! -d $NARROW_CLASS_DIR ]]; then
	mkdir -p $NARROW_CLASS_DIR
fi

if [[ ! -d $STRAIGHT_SEG_DIR ]]; then
	mkdir -p $STRAIGHT_SEG_DIR
fi

if [[ ! -d $CTA2D_DIR ]]; then
	mkdir -p $CTA2D_DIR
fi

if [[ ! -d $CTA_MYOCARDIUM_DIR ]]; then
  mkdir -p $CTA_MYOCARDIUM_DIR
fi

if [[ ! -d $CTA_STRAIGHT_QUALIFIER_DIR ]]; then
  mkdir -p $CTA_STRAIGHT_QUALIFIER_DIR
fi

if [[ ! -d $CTA_DENOISE_DIR ]]; then
  mkdir -p $CTA_DENOISE_DIR
fi

if [[ ! -d $CTA_CPR_CHECKER_DIR ]]; then
  mkdir -p $CTA_CPR_CHECKER_DIR
fi

update(){
  app_name=$1
  app_version=$2
  app_dir=$3
  cd $app_dir
  wget --http-user=$RELEASE_SERVER_USER --http-password=$RELEASE_SERVER_PWD http://103.211.47.132:99/$app_name/releases/$app_version/$app_name-$app_version.tar.gz
  tar -xzvf $app_name-$app_version.tar.gz
  rm -rf $app_dir/latest
  ln -s $app_version ./latest
  rm -rf $app_name-$app_version.tar.gz
  echo "add ops center update record"
  curl -l -H "Content-type: application/json" -H "token: shukun111222" -X POST -d "{\"workStation\":{\"name\":\"$PROD_ID\"},\"appVersion\":{\"name\":\"$app_name\", \"version\":\"$app_version\"}}" http://103.211.47.132:9092/api/v1/workstationupdates
}

if [[ ! -z $CTA3D_VERSION ]]; then
	cd $CTA3D_DIR
  APP_NAME=cta3d
	wget --http-user=$RELEASE_SERVER_USER --http-password=$RELEASE_SERVER_PWD http://103.211.47.132:99/$APP_NAME/releases/$CTA3D_VERSION/$APP_NAME-$CTA3D_VERSION.tar.gz
	tar -xzvf $APP_NAME-$CTA3D_VERSION.tar.gz
	rm -rf $CTA3D_DIR/latest
	ln -s $CTA3D_VERSION ./latest
	rm -rf $APP_NAME-$CTA3D_VERSION.tar.gz
  echo "add ops center update record"
  curl -l -H "Content-type: application/json" -H "token: shukun111222" -X POST -d "{\"workStation\":{\"name\":\"$PROD_ID\"},\"appVersion\":{\"name\":\"$APP_NAME\", \"version\":\"$CTA3D_VERSION\"}}" http://103.211.47.132:9092/api/v1/workstationupdates
fi

if [[ ! -z $CTA2D_VERSION ]]; then
	cd $CTA2D_DIR
  APP_NAME=cta2d
	wget --http-user=$RELEASE_SERVER_USER --http-password=$RELEASE_SERVER_PWD http://103.211.47.132:99/$APP_NAME/releases/$CTA2D_VERSION/$APP_NAME-$CTA2D_VERSION.tar.gz
	tar -xzvf $APP_NAME-$CTA2D_VERSION.tar.gz
	rm -rf $CTA2D_DIR/latest
	ln -s $CTA2D_VERSION ./latest
	rm -rf $APP_NAME-$CTA2D_VERSION.tar.gz
  echo "add ops center update record"
  curl -l -H "Content-type: application/json" -H "token: shukun111222" -X POST -d "{\"workStation\":{\"name\":\"$PROD_ID\"},\"appVersion\":{\"name\":\"$APP_NAME\", \"version\":\"$CTA2D_VERSION\"}}" http://103.211.47.132:9092/api/v1/workstationupdates
fi

if [[ ! -z $NARROW_CLASS_VERSION ]]; then
	cd $NARROW_CLASS_DIR
  APP_NAME=cta_narrow_classification
	wget --http-user=$RELEASE_SERVER_USER --http-password=$RELEASE_SERVER_PWD http://103.211.47.132:99/$APP_NAME/releases/$NARROW_CLASS_VERSION/$APP_NAME-$NARROW_CLASS_VERSION.tar.gz
	tar -xzvf $APP_NAME-$NARROW_CLASS_VERSION.tar.gz
	rm -rf $NARROW_CLASS_DIR/latest
	ln -s $NARROW_CLASS_VERSION ./latest
	rm -rf $APP_NAME-$NARROW_CLASS_VERSION.tar.gz
  echo "add ops center update record"
  curl -l -H "Content-type: application/json" -H "token: shukun111222" -X POST -d "{\"workStation\":{\"name\":\"$PROD_ID\"},\"appVersion\":{\"name\":\"$APP_NAME\", \"version\":\"$NARROW_CLASS_VERSION\"}}" http://103.211.47.132:9092/api/v1/workstationupdates
fi

if [[ ! -z $STRAIGHT_SEG_VERSION ]]; then
	cd $STRAIGHT_SEG_DIR
  APP_NAME=cta_straight_seg
	wget --http-user=$RELEASE_SERVER_USER --http-password=$RELEASE_SERVER_PWD http://103.211.47.132:99/$APP_NAME/releases/$STRAIGHT_SEG_VERSION/$APP_NAME-$STRAIGHT_SEG_VERSION.tar.gz
	tar -xzvf $APP_NAME-$STRAIGHT_SEG_VERSION.tar.gz
	rm -rf $STRAIGHT_SEG_DIR/latest
	ln -s $STRAIGHT_SEG_VERSION ./latest
	rm -rf $APP_NAME-$STRAIGHT_SEG_VERSION.tar.gz
  echo "add ops center update record"
  curl -l -H "Content-type: application/json" -H "token: shukun111222" -X POST -d "{\"workStation\":{\"name\":\"$PROD_ID\"},\"appVersion\":{\"name\":\"$APP_NAME\", \"version\":\"$STRAIGHT_SEG_VERSION\"}}" http://103.211.47.132:9092/api/v1/workstationupdates
fi

if [[ ! -z $CTA_MYOCARDIUM_VERSION ]]; then
  cd $CTA_MYOCARDIUM_DIR
  APP_NAME=cta_myocardium
  wget --http-user=$RELEASE_SERVER_USER --http-password=$RELEASE_SERVER_PWD http://103.211.47.132:99/$APP_NAME/releases/$CTA_MYOCARDIUM_VERSION/$APP_NAME-$CTA_MYOCARDIUM_VERSION.tar.gz
  tar -xzvf $APP_NAME-$CTA_MYOCARDIUM_VERSION.tar.gz
  rm -rf $CTA_MYOCARDIUM_DIR/latest
  ln -s $CTA_MYOCARDIUM_VERSION ./latest
  rm -rf $APP_NAME-$CTA_MYOCARDIUM_VERSION.tar.gz
  echo "add ops center update record"
  curl -l -H "Content-type: application/json" -H "token: shukun111222" -X POST -d "{\"workStation\":{\"name\":\"$PROD_ID\"},\"appVersion\":{\"name\":\"$APP_NAME\", \"version\":\"$CTA_MYOCARDIUM_VERSION\"}}" http://103.211.47.132:9092/api/v1/workstationupdates
fi

if [[ ! -z $CTA_STRAIGHT_QUALIFIER_VERSION ]]; then
  cd $CTA_STRAIGHT_QUALIFIER_DIR
  APP_NAME=cta_straight_qualifier
  wget --http-user=$RELEASE_SERVER_USER --http-password=$RELEASE_SERVER_PWD http://103.211.47.132:99/$APP_NAME/releases/$CTA_STRAIGHT_QUALIFIER_VERSION/$APP_NAME-$CTA_STRAIGHT_QUALIFIER_VERSION.tar.gz
  tar -xzvf $APP_NAME-$CTA_STRAIGHT_QUALIFIER_VERSION.tar.gz
  rm -rf $CTA_STRAIGHT_QUALIFIER_DIR/latest
  ln -s $CTA_STRAIGHT_QUALIFIER_VERSION ./latest
  rm -rf $APP_NAME-$CTA_STRAIGHT_QUALIFIER_VERSION.tar.gz
  echo "add ops center update record"
  curl -l -H "Content-type: application/json" -H "token: shukun111222" -X POST -d "{\"workStation\":{\"name\":\"$PROD_ID\"},\"appVersion\":{\"name\":\"$APP_NAME\", \"version\":\"$CTA_STRAIGHT_QUALIFIER_VERSION\"}}" http://103.211.47.132:9092/api/v1/workstationupdates
fi

if [[ ! -z $CTA_DENOISE_VERSION ]]; then
  cd $CTA_DENOISE_DIR
  APP_NAME=cta_denoise
  wget --http-user=$RELEASE_SERVER_USER --http-password=$RELEASE_SERVER_PWD http://103.211.47.132:99/$APP_NAME/releases/$CTA_DENOISE_VERSION/$APP_NAME-$CTA_DENOISE_VERSION.tar.gz
  tar -xzvf $APP_NAME-$CTA_DENOISE_VERSION.tar.gz
  rm -rf $CTA_DENOISE_DIR/latest
  ln -s $CTA_DENOISE_VERSION ./latest
  rm -rf $APP_NAME-$CTA_DENOISE_VERSION.tar.gz
  echo "add ops center update record"
  curl -l -H "Content-type: application/json" -H "token: shukun111222" -X POST -d "{\"workStation\":{\"name\":\"$PROD_ID\"},\"appVersion\":{\"name\":\"$APP_NAME\", \"version\":\"$CTA_DENOISE_VERSION\"}}" http://103.211.47.132:9092/api/v1/workstationupdates
fi

if [[ ! -z $CTA_CPR_CHECKER_VERSION ]]; then
  cd $CTA_CPR_CHECKER_DIR
  APP_NAME=cta_cpr_checker
  wget --http-user=$RELEASE_SERVER_USER --http-password=$RELEASE_SERVER_PWD http://103.211.47.132:99/$APP_NAME/releases/$CTA_CPR_CHECKER_VERSION/$APP_NAME-$CTA_CPR_CHECKER_VERSION.tar.gz
  tar -xzvf $APP_NAME-$CTA_CPR_CHECKER_VERSION.tar.gz
  rm -rf $CTA_CPR_CHECKER_DIR/latest
  ln -s $CTA_CPR_CHECKER_VERSION ./latest
  rm -rf $APP_NAME-$CTA_CPR_CHECKER_VERSION.tar.gz
  echo "add ops center update record"
  curl -l -H "Content-type: application/json" -H "token: shukun111222" -X POST -d "{\"workStation\":{\"name\":\"$PROD_ID\"},\"appVersion\":{\"name\":\"$APP_NAME\", \"version\":\"$CTA_CPR_CHECKER_VERSION\"}}" http://103.211.47.132:9092/api/v1/workstationupdates
fi


