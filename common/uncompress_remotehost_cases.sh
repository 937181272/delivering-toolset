#!/bin/bash
#登陆远程服务器解压上传的压缩包
#删除原文件：
ssh -p 6922 databackup@103.211.47.132 'cd /home/databackup/hanzhong-001;pwd ;for i in `ls /home/databackup/hanzhong-001/`; do tar -xzvf $i; rm -rf $i; done'
#不删除原文件：
#ssh -p 6922 databackup@103.211.47.132 'cd /home/databackup/hanzhong-001;pwd ;for i in `ls /home/databackup/hanzhong-001/`; do tar -xzvf $i; done'


