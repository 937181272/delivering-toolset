#!/bin/bash
set -ex
#此脚本的功能是收集指定病例到本地指定目录下：
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

SOURCE_DIR=/data0/rundata/cta_srv_cases
TARGET_DIR=/data0/rundata/collected_cases
#判断目标目录是否存在：
if [ ! -d "$TARGET_DIR" ];then
    mkdir $TARGET_DIR
fi

cd $SOURCE_DIR
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
    if [ -d "$SOURCE_DIR/$line" ];then
        tar -czvf "$line".tar.gz "$line"/*.dcm
        mv "$line".tar.gz "$TARGET_DIR"
    fi

done < FILE_LIST

rm -f FILE_LIST


