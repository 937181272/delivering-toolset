#!/usr/bin/env bash
set -e

APP_NAME=$1
APP_VERSION=$2
SRC_PATH=/data/medicaldata/report/releases_offline/cta
DIST_PATH=/home/devops1/projects/dist/$APP_NAME/$APP_VERSION
FILE_NAME=$APP_NAME-$APP_VERSION.tar.gz
SRC_FILE=$SRC_PATH/$APP_VERSION/$APP_NAME-$APP_VERSION.tar

if [ ! -f "$SRC_FILE" ];then
	echo "source file $SRC_FILE is not existing, exit"
	exit 1
fi

echo "> move release to distination dir ..."
rm -rf $DIST_PATH
mkdir -p $DIST_PATH
cp $SRC_FILE $DIST_PATH
 
echo "> uncompress file $APP_NAME-$APP_VERSION.tar"
cd $DIST_PATH
tar -xvf $APP_NAME-$APP_VERSION.tar

echo "> create new build shell"
echo '#!/usr/bin/env bash' > cta_seg_release/build/build.sh
echo 'VERSION=$(cat ../.version)' >> cta_seg_release/build/build.sh
echo 'tar cvf cta_seg_release.tar ../../cta_seg_release --exclude=.git*' >> cta_seg_release/build/build.sh
echo 'docker build . -t shukun/cta:"$VERSION"' >> cta_seg_release/build/build.sh
echo 'docker tag shukun/cta:"$VERSION" shukun/cta:latest' >> cta_seg_release/build/build.sh

echo "> compress file $FILE_NAME"
tar -zcvf $APP_NAME-$APP_VERSION.tar.gz cta_seg_release

echo "> remove unused file ... "
rm -rf cta_seg_release
rm -rf $APP_NAME-$APP_VERSION.tar

echo "> package $FILE_NAME finished, file list: "
ls -al

curl -l -H "Content-type: application/json" -H "token: shukun111222" -X POST -d "{\"name\":\"$APP_NAME\",\"version\":\"$APP_VERSION\",\"catalog\":\"alg\"}" http://103.211.47.132:9092/api/v1/appversions
