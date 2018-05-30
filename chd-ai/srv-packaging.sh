#!/usr/bin/env bash
set -e

APP_NAME=$1
APP_VERSION=$2
DIST_PATH=/home/devops1/projects/dist/$APP_NAME/$APP_VERSION
FILE_NAME=$APP_NAME-$APP_VERSION.tar.gz

echo "packaging file ..."
rm -rf $FILE_NAME
cd $APP_NAME

echo "> switch to specified version tag: $APP_VERSION"
git checkout $APP_VERSION
ls -al
cd ..

echo "> compress $APP_NAME @APP_VERSION"
tar -zcvf $FILE_NAME $APP_NAME
echo "packaged file $FILE_NAME"

echo "> move release to distination dir"
rm -rf $DIST_PATH
mkdir $DIST_PATH
cp $FILE_NAME $DIST_PATH

echo "add ops center release record"
curl -l -H "Content-type: application/json" -H "token: shukun111222" -X POST -d "{\"name\":\"$APP_NAME\",\"version\":\"$APP_VERSION\",\"catalog\":\"backend\"}" http://103.211.47.132:9092/api/v1/appversions

echo "> package finished"