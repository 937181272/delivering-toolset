#!/usr/bin/env bash
set -e

APP_NAME=$1
APP_VERSION=$2
APP_LEVEL=$3
DIST_PATH=/home/devops1/projects/dist/$APP_NAME/$APP_VERSION
FILE_NAME=$APP_LEVEL-$APP_NAME-$APP_VERSION.tar.gz

echo "> install npm dependences and run build ..."
cd $APP_NAME

echo "> switch to new version $APP_VERSION"
git checkout $APP_VERSION

#rm -rf node_modules
export PATH=/opt/node-v8.4.0-linux-x64/bin:$PATH
yarn install

#export AUTH_MODE='local'
#npm run build
yarn build --config-file $APP_LEVEL

./install.sh

echo "> packaging file ..."
cd ..
rm -rf $FILE_NAME
cd $APP_NAME
cp -R public $APP_NAME/
#cp install.sh $APP_NAME/
cp VERSION $APP_NAME/
rm -rf $APP_NAME/files
ls -al $APP_NAME/
tar -zcvf $FILE_NAME $APP_NAME
rm -rf $APP_NAME
echo "> packaged file $FILE_NAME"

echo "> move release to distination dir"
if [[ ! -d $DIST_PATH ]]; then
	mkdir -p $DIST_PATH
fi
cp $FILE_NAME $DIST_PATH

echo "add ops center release record"
curl -l -H "Content-type: application/json" -H "token: shukun111222" -X POST -d "{\"name\":\"$APP_NAME\",\"version\":\"$APP_VERSION\",\"catalog\":\"frontend\",\"appLevel\":\"$APP_LEVEL\"}" http://103.211.47.132:9092/api/v1/appversions

echo "> package finished"