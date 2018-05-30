#!/bin/bash
#此脚本的作用是可按行读取本地的压缩文件列表compress_filelist和本地的已被压缩过的标识文件作对比，只压缩上传压缩文件列表里新的文件，第一次全压。也可以将要压缩的文件手动写入LOCAL_DIR目录下的compress_filelist中，从而只压缩文件列表中的指定文件：
LOCAL_DIR=/data0/rundata
REMOTE_DIR=/data/medicaldata/hospital_online/hanzhong-001/cta_srv_cases
cd /data0/rundata
#若不存在压缩标识文件，则创建该文件：
if [ ! -f "$LOCAL_DIR/fileinfo" ];then
    echo "压缩标识文件fileinfo不存在！"
    touch fileinfo
fi

#若不存在压缩文件列表，则创建该文件：
if [ ! -f "$LOCAL_DIR/compress_filelist" ];then
    echo "压缩文件列表compress_filelist不存在！"
    touch compress_filelist
fi
#若不存在支架压缩文件列表，则创建该文件：
if [ ! -f "$LOCAL_DIR/compress_filelist_stent" ];then
    echo "支架压缩文件列表compress_filelist_stent不存在！"
    touch compress_filelist_stent
fi

cd /data0/rundata/cta_srv_cases
#按行读取压缩文件列表compress_filelist里的内容：
while read line
do
#    if [ ! `grep "$line" $LOCAL_DIR/fileinfo` ]; then
#   -z判断字符串为空 -n判断字符串为非空
    if [ -z $"`grep "$line" $LOCAL_DIR/fileinfo`" ]; then
        tar -czvf "$line".tar.gz "$line"
        echo $line >> ../fileinfo
        scp -P 6922 "$line".tar.gz databackup@103.211.47.132:"$REMOTE_DIR"
        rm -rf "$line".tar.gz
    else
        continue
    fi
done < ../compress_filelist
#按行读取支架压缩文件列表compress_filelist_stent里的内容：
while read line
do
    if [ -z $"`grep "$line" $LOCAL_DIR/fileinfo`" ]; then
        tar -czvf "$line".tar.gz "$line"
        echo $line >> ../fileinfo
        scp -P 6922 "$line".tar.gz databackup@103.211.47.132:"$REMOTE_DIR/stent"
        rm -rf "$line".tar.gz
    else
        continue
    fi
done < ../compress_filelist_stent
#登陆远程服务器解压上传的压缩包并删除原文件
#ssh -p 6922 databackup@103.211.47.132 'cd /home/databackup/hanzhong-001;pwd ;for i in `ls /home/databackup/hanzhong-001/`; do tar -xzvf $i; rm -rf $i; done'



