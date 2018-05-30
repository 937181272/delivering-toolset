# !/bin/sh
set -e
#将磁盘使用情况写到临时文件下：
df -h
USE=`df -h | grep -o [0-9]*% | grep -o '[0-9]\+'`
PROD_INSTANCE_ID=$1
for i in $USE
do
if (( $i > 90 ))
then
    echo "warning:low disk usage for $PROD_INSTANCE_ID,please clean up as soon as possible" | mail -s "Warning:Low disk space for $i" -t 937181272@qq.com
fi
if (( $i > 85 ))
then
    echo "watch out:the disk of $PROD_INSTANCE_ID space is low,please clean up quickily" | mail -s "Watch out:Low disk space for $i" -t 937181272@qq.com
fi
done

