#!/bin/bash
#此脚本的作用是增量压缩本地指定目录下的所有文件夹到本地指定目录上：
LOCAL_DIR=/data0/rundata/cta_crv_cases
filelist=$(ls -l "$LOCAL_DIR" |awk '/^d/ {print $NF}')
REMOTE_DATA_DIR=/media/amax/4E7B-CEAD/hanzhong_cta_crv_cases

cd "$LOCAL_DIR"
if [ ! -f "$LOCAL_DIR/fileinfo" ];then
    echo "压缩标识文件fileinfo不存在！"
    touch fileinfo
fi

for i in $filelist
do
#    if [ `grep -c "$i" $LOCAL_DIR/fileinfo` -eq '0' ]; then
    if [ -z $"`grep "$i" $LOCAL_DIR/fileinfo`" ]; then
        tar -czvf "$REMOTE_DATA_DIR/$i".tar.gz "$i"
        echo $i >> ./fileinfo
    else
        continue
    fi
done

#登陆远程服务器解压上传的压缩包并删除原文件
#ssh -p 6922 databackup@103.211.47.132 'cd /home/databackup/hanzhong-001;pwd ;for i in `ls /home/databackup/hanzhong-001/`; do tar -xzvf $i; rm -rf $i; done'



