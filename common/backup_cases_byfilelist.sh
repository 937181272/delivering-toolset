#!/bin/bash
#此脚本的作用是可按行读取本地的压缩文件列表compress_filelist和本地的已被压缩过的标识文件作对比，只压缩上传压缩文件列表里新的文件，第一次全压。也可以将要压缩的文件手动写入LOCAL_DIR目录下的compress_filelist中，从而只压缩文件列表中的指定文件：
LOCAL_DIR=/Users/shukun/Documents/delivering-toolset/
REMOTE_DIR=/home/databackup/hanzhong-001
cd $LOCAL_DIR
#若不存在压缩标识文件，则创建该文件：
if [ ! -f "$LOCAL_DIR/fileinfo" ];then
    echo "压缩标识文件fileinfo不存在！"
    touch fileinfo
fi

#若不存在压缩文件列表，则创建该文件：
if [ ! -f "$LOCAL_DIR/compress_filelist" ];then
    echo "压缩文件列表compress_filelist不存在！"
    touch compress_filelist
    #生成指定目录下的所有文件到文件列表：
    filelist=$(ls -l "$LOCAL_DIR" |awk '/^d/ {print $NF}')
    for i in $filelist
    do
        echo "$i" >> ./compress_filelist
    done
fi

#按行读取压缩文件列表compress_filelist里的内容：
while read line
do
#    if [ ! `grep "$line" $LOCAL_DIR/fileinfo` ]; then
#   -z判断字符串为空 -n判断字符串为非空
    if [ -z $"`grep "$line" $LOCAL_DIR/fileinfo`" ]; then
        tar -czvf "$line".tar.gz "$line"
        echo $line >> ./fileinfo
        scp -P 6922 "$line".tar.gz databackup@103.211.47.132:"$REMOTE_DIR"
        rm -rf "$line".tar.gz
    else
        continue
    fi
done < compress_filelist

#登陆远程服务器解压上传的压缩包并删除原文件
#ssh -p 6922 databackup@103.211.47.132 'cd /home/databackup/hanzhong-001;pwd ;for i in `ls /home/databackup/hanzhong-001/`; do tar -xzvf $i; rm -rf $i; done'



