#!/bin/bash
set -e

function usage()
{
	echo "usage: $0 <db_user> <db_pwd> <db_name>  <prod_instance_id>"
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

echo "start to backup mysql data ..."
DB_USER=$1
DB_PWD=$2
DB_NAME=$3
PROD_INSTANCE_ID=$4

LOCAL_DATA_DIR=/data0/rundata
REMOTE_DATA_DIR=/data/medicaldata/hospital_online

MYSQL_BACKUP_DIR=$LOCAL_DATA_DIR/backups/mysql

if [ ! -d $MYSQL_BACKUP_DIR ];then
	mkdir -p $MYSQL_BACKUP_DIR
fi
cd $MYSQL_BACKUP_DIR

echo "backup db $DB_NAME ..."
DATE=`date +%Y%m%d%H%M%S`
docker exec cta-mysql sh -c "exec mysqldump -u$DB_USER -p$DB_PWD $DB_NAME" > $DATE.sql
echo "backup data done, sql script file is: $DATE.sql"
echo "zip backup data ..."
rm -rf latest_data.tar.gz
tar -czvf latest_data.tar.gz $DATE.sql
echo "zip backup data done"

cd $MYSQL_BACKUP_DIR
ssh -p 6922 databackup@103.211.47.132 "if [ ! -d $REMOTE_DATA_DIR/$PROD_INSTANCE_ID/mysql ];then mkdir -p $REMOTE_DATA_DIR/$PROD_INSTANCE_ID/mysql; fi"
scp -P 6922 latest_data.tar.gz databackup@103.211.47.132:$REMOTE_DATA_DIR/$PROD_INSTANCE_ID/mysql
ssh -p 6922 databackup@103.211.47.132 "cd $REMOTE_DATA_DIR/$PROD_INSTANCE_ID/mysql; tar  -zxvf latest_data.tar.gz"