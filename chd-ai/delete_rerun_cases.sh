#!/bin/bash
# 此脚本用于本地重跑任意多个病例，执行方法是：sudo ./delete_rerun_cases.sh P* P* P*
set -ex

function usage()
{
echo "usage: $0 <Medical Number1> <Medical Number2> ……"
echo "eg: $0 P……"
exit
}

if [[ $# == 0 ]]; then
usage
fi

LOCAL_DIR=/data0/rundata
SRV_DIR=/data0/rundata/cta_srv_cases
OUTPUT_DIR=/data0/rundata/cta_srv_output
cd $LOCAL_DIR
#判断文件列表是否存在，存在则删除：
if [ -f "$LOCAL_DIR/FILE_LIST" ];then
    rm -rf $LOCAL_DIR/FILE_LIST
fi

touch FILE_LIST
echo %@
for i in $@;do
    if echo "$i" | grep -E '^P'>>$LOCAL_DIR/FILE_LIST;then echo "true";fi
done

#按行读取压缩文件列表compress_filelist里的内容：
while read line
do
    curl -v -X DELETE http://localhost:5000/cases/$line
    if [ -d "$SRV_DIR/$line" ];then
        rm -rf "$SRV_DIR/$line"
    fi

    if [ -d "$OUTPUT_DIR/$line" ];then
        rm -rf "$OUTPUT_DIR/$line"
    fi

done < $LOCAL_DIR/FILE_LIST

rm -f $LOCAL_DIR/FILE_LIST





