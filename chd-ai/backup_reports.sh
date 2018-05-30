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

PROD_INSTANCE_ID=$1
DATE=`date +%Y%m%d%H%M%S`
TAR_FILE=reports_$DATE.tar.gz

#case数据增量备份标识
FLAG_FILE=report_flag

cd $LOCAL_DATA_DIR
tar -g $FLAG_FILE -zcvf $TAR_FILE reports

ssh -p 6922 databackup@103.211.47.132 "if [ ! -d $REMOTE_DATA_DIR/$PROD_INSTANCE_ID/reports ];then mkdir -p $REMOTE_DATA_DIR/$PROD_INSTANCE_ID/reports; fi"
scp -P 6922 $TAR_FILE databackup@103.211.47.132:$REMOTE_DATA_DIR/$PROD_INSTANCE_ID/reports