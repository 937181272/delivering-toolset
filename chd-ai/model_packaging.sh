#!/usr/bin/env bash
set -e

APP_NAME=$1
APP_VERSION=$2
MODEL_PATH=/data/medicaldata/modelout
DIST_PATH=/home/devops1/projects/dist/$APP_NAME/releases/$APP_VERSION
FILE_NAME=$APP_NAME-$APP_VERSION.tar.gz

cd $MODEL_PATH/$APP_NAME/releases
echo "> file list in current dir ..."
ls -al
rm -rf $FILE_NAME

echo "> package ..."
if [[ ! -d $APP_VERSION ]]; then
	echo "> app version $APP_VERSION is not existing"
	exit 1
fi
tar -zcvf $FILE_NAME $APP_VERSION

echo "> move release to distination dir ..."
rm -rf $DIST_PATH
mkdir -p $DIST_PATH
cp $FILE_NAME $DIST_PATH

echo "add ops center release record"
curl -l -H "Content-type: application/json" -H "token: shukun111222" -X POST -d "{\"name\":\"$APP_NAME\",\"version\":\"$APP_VERSION\",\"catalog\":\"model\"}" http://103.211.47.132:9092/api/v1/appversions

echo "> package $FILE_NAME finished"