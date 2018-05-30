#!/usr/bin/env bash
set -e

function usage()
{
	echo "TEST_DATA_VERSION error"
	echo "Try an existing TEST_DATA_VERSION"
	exit
}

if [[ $# != 1 ]]; then
	usage
fi

RELEASE_SERVER_USER=devops1
RELEASE_SERVER_PWD=skRelease!Pwd
DATA_PATH=/data0/rundata/cta_srv_cases
TEST_DATA_VERSION=$1


cd $DATA_PATH
echo '> download test data ...'
wget --http-user=$RELEASE_SERVER_USER --http-password=$RELEASE_SERVER_PWD http://103.211.47.132:99/check_cases/$TEST_DATA_VERSION/check_cases-$TEST_DATA_VERSION.tar.gz
tar -xzvf check_cases-$TEST_DATA_VERSION.tar.gz
rm check_cases-$TEST_DATA_VERSION.tar.gz

