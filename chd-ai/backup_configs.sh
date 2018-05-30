#!/bin/bash

function usage()
{
	echo "usage: $0 <product_instance_id>"
	echo "eg: $0 zdyfy-001"
	exit
}

if [[ $# != 1 ]]; then
	usage
fi

LOCAL_DATA_DIR=/data0/rundata
REMOTE_DATA_DIR=/data/medicaldata/hospital_online
MONGO_BACKUP_DIR=$LOCAL_DATA_DIR/backups/configs

PROD_INSTANCE_ID=$1
DATE=`date +%Y%m%d%H%M%S`
TAR_FILE=configs_$DATE.tar.gz

cd /home/devops1/sk/medicalbrain-cta-srv/
tar -zcvf $TAR_FILE configs

if [ ! -d $MONGO_BACKUP_DIR/$DATE ];then
	mkdir -p $MONGO_BACKUP_DIR
fi
mv $TAR_FILE $MONGO_BACKUP_DIR

ssh -p 6922 databackup@103.211.47.132 "if [ ! -d $REMOTE_DATA_DIR/$PROD_INSTANCE_ID/configs ];then mkdir -p $REMOTE_DATA_DIR/$PROD_INSTANCE_ID/configs; fi"
scp -P 6922 $MONGO_BACKUP_DIR/$TAR_FILE databackup@103.211.47.132:$REMOTE_DATA_DIR/$PROD_INSTANCE_ID/configs