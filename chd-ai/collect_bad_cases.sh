#!/bin/bash
#此脚本的作用是可按行读取本地的压缩文件列表compress_filelist和本地的已被压缩过的标识文件作对比，只压缩上传压缩文件列表里新的文件，第一次全压。也可以将要压缩的文件手动写入LOCAL_DIR目录下的compress_filelist中，从而只压缩文件列表中的指定文件：
set -e

function usage()
{
echo "usage: $0 <PROD_INSTANCE_ID>"
echo "eg: $0 PROD_INSTANCE_ID"
exit
}

if [[ $# != 1 ]]; then
usage
fi

PROD_INSTANCE_ID=$1

LOCAL_DIR=/data0/rundata
LOCAL_BAD_CASE_DIR=$LOCAL_DIR/bad_cases
LOCAL_CASES_DIR=$LOCAL_DIR/cta_srv_cases
REMOTE_BAD_CASE_DIR=/data/medicaldata/hospital_online/"$PROD_INSTANCE_ID"/bad_cases
COMPRESS_FILELIST=compress_filelist
COMPRESS_STENT_FILELIST=compress_filelist_stent
COMPRESSED_FILELIST=compressed_filelist

if [[ ! -d $LOCAL_BAD_CASE_DIR ]]; then
    mkdir -p $LOCAL_BAD_CASE_DIR
fi

if [[ ! -d $LOCAL_BAD_CASE_DIR/stent ]]; then
    mkdir -p $LOCAL_BAD_CASE_DIR/stent
fi

#若不存在压缩标识文件，则创建该文件：
if [ ! -f "$LOCAL_BAD_CASE_DIR/compressed_filelist" ];then
    echo "压缩标识文件compressed_filelist不存在！"
    touch $LOCAL_BAD_CASE_DIR/compressed_filelist
fi

#若不存在压缩文件列表，则创建该文件：
if [ ! -f "$LOCAL_BAD_CASE_DIR/compress_filelist" ];then
    echo "压缩文件列表compress_filelist不存在！"
    touch $LOCAL_BAD_CASE_DIR/compress_filelist
fi
#若不存在支架压缩文件列表，则创建该文件：
if [ ! -f "$LOCAL_BAD_CASE_DIR/compress_filelist_stent" ];then
    echo "支架压缩文件列表compress_filelist_stent不存在！"
    touch $LOCAL_BAD_CASE_DIR/compress_filelist_stent
fi

ssh -p 6922 databackup@103.211.47.132 "if [ ! -d $REMOTE_BAD_CASE_DIR ];then mkdir -p $REMOTE_BAD_CASE_DIR; fi"
ssh -p 6922 databackup@103.211.47.132 "if [ ! -d $REMOTE_BAD_CASE_DIR/stent ];then mkdir -p $REMOTE_BAD_CASE_DIR/stent; fi"

cd $LOCAL_BAD_CASE_DIR
#按行读取压缩文件列表compress_filelist里的内容：
while read line
do
    if [ -z $"`grep "$line" $COMPRESSED_FILELIST`" ]; then
        tar -czvf $line.tar.gz $LOCAL_CASES_DIR/$line
        echo $line >> $COMPRESSED_FILELIST
        scp -P 6922 $line.tar.gz databackup@103.211.47.132:"/data/medicaldata/hospital_online/$PROD_INSTANCE_ID/bad_cases"
    fi
done < compress_filelist

#按行读取支架压缩文件列表compress_filelist_stent里的内容：
while read line
do
    if [ -z $"`grep $line $COMPRESSED_FILELIST`" ]; then
        tar -czvf stent/$line.tar.gz $LOCAL_CASES_DIR/$line
        echo $line >> $COMPRESSED_FILELIST
        scp -P 6922 stent/$line.tar.gz databackup@103.211.47.132:"/data/medicaldata/hospital_online/$PROD_INSTANCE_ID/bad_cases/stent"
    fi
done < compress_filelist_stent



