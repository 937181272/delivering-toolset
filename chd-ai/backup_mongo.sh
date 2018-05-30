#!/bin/bash
set -e

function usage()
{
	echo "usage: $0 <db_user> <db_pwd> <db_name> <prod_instance_id>"
	echo "eg: $0 test_user test_pwd test_db"
	echo 'db_user: db username'
	echo 'db_pwd: db password'
	echo 'db_name: db name'
	echo 'prod_instance_id: product instance id'
	exit
}

if [[ $# != 4 ]]; then
	usage
fi

echo "start to backup mongo data ..."
DB_USER=$1
DB_PWD=$2
DB_NAME=$3
PROD_INSTANCE_ID=$4

echo "backup db $DB_NAME ..."

WORKSPACE=/home/devops1/sk
LOCAL_DATA_DIR=/data0/rundata
REMOTE_DATA_DIR=/data/medicaldata/hospital_online

MONGO_DIR=$WORKSPACE/data/mongo
MONGO_BACKUP_DIR=$LOCAL_DATA_DIR/backups/mongo
DATE=`date +%Y%m%d%H%M%S`

docker exec -i cta-mongo bash -c "mongodump -v --host localhost --port 27017 --db $DB_NAME --username $DB_USER --password $DB_PWD --out=/data/db/backups"

if [ ! -d $MONGO_BACKUP_DIR/$DATE ];then
	mkdir -p $MONGO_BACKUP_DIR/$DATE
fi
cp -r $MONGO_DIR/backups/* $MONGO_BACKUP_DIR/$DATE
echo "data is backup to dir $MONGO_BACKUP_DIR/$DATE"

cd $MONGO_BACKUP_DIR
tar -czvf $DATE.tar.gz $DATE
ssh -p 6922 databackup@103.211.47.132 "if [ ! -d $REMOTE_DATA_DIR/$PROD_INSTANCE_ID/mongo ];then mkdir -p $REMOTE_DATA_DIR/$PROD_INSTANCE_ID/mongo; fi"
scp -P 6922 $DATE.tar.gz databackup@103.211.47.132:$REMOTE_DATA_DIR/$PROD_INSTANCE_ID/mongo