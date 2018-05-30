#!/bin/bash
set -ex

function usage()
{
echo "usage: $0 <FILE_LIST> <PROD_INSTANCE_ID>"
echo "eg: $0 FILE_LIST PROD_INSTANCE_ID"
exit
}

if [[ $# == 1 ]]; then
    usage
fi

PROD_INSTANCE_ID=$1

LOCAL_DIR=/data0/rundata/cta_srv_cases
REMOTE_DIR=/data/medicaldata/hospital_online/"$PROD_INSTANCE_ID"/cta_srv_cases
cd $LOCAL_DIR
#判断文件列表是否存在，存在则删除：
if [ -f "./FILE_LIST" ];then
    rm -rf ./FILE_LIST
fi

touch FILE_LIST
echo %@
for i in $@;do
    if echo "$i" | grep -E '^P'>>./FILE_LIST;then echo "true";fi
done

#按行读取压缩文件列表compress_filelist里的内容：
while read line
do
#   -z判断字符串为空 -n判断字符串为非空
    if [ -d "$LOCAL_DIR/$line" ];then
        tar -czvf "$line".tar.gz "$line"/*.dcm
        scp -P 6922 "$line".tar.gz databackup@103.211.47.132:"$REMOTE_DIR"
        rm -rf "$line".tar.gz
    fi

done < FILE_LIST

rm -f FILE_LIST


