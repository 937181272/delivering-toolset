#! /bin/bash
# 该脚本可以监控磁盘的网络联通情况，IP内网及外网地址，磁盘各个分区的使用情况，只适用于ubuntu系统：
# clear the screen
clear
# unset any variable which system may be using
unset tecreset os architecture kernelrelease internalip externalip nameserver loadaverage
while getopts iv name
do
        case $name in
          i)iopt=1;;
          v)vopt=1;;
          *)echo "Invalid arg";;
        esac
done

if [[ ! -z $iopt ]]
then
{
wd=$(pwd)
basename "$(test -L "$0" && readlink "$0" || echo "$0")" > /tmp/scriptname
scriptname=$(echo -e -n $wd/ && cat /tmp/scriptname)
su -c "cp $scriptname /usr/bin/monitor" root && echo "Congratulations! Script Installed, now run monitor Command" || echo "Installation failed"
}
fi

if [[ ! -z $vopt ]]
then
{
echo -e "tecmint_monitor version 0.1\nDesigned by Tecmint.com\nReleased Under Apache 2.0 License"
}
fi

if [[ $# -eq 0 ]]
then
{


# 定义tecreset变量：
tecreset=$(tput sgr0)

# 检查网络连接是否正常：
ping -c 1 google.com &> /dev/null && echo -e '\E[32m'"Internet: $tecreset Connected" || echo -e '\E[32m'"Internet: $tecreset Disconnected"

# 检查OS类型：
os=$(uname -o)
echo -e '\E[32m'"Operating System Type :" $tecreset $os

# 检查OS的名称和版本：
cat /etc/os-release | grep 'NAME\|VERSION' | grep -v 'VERSION_ID' | grep -v 'PRETTY_NAME' > /tmp/osrelease
echo -n -e '\E[32m'"OS Name :" $tecreset  && cat /tmp/osrelease | grep -v "VERSION" | cut -f2 -d\"
echo -n -e '\E[32m'"OS Version :" $tecreset && cat /tmp/osrelease | grep -v "NAME" | cut -f2 -d\"

# 检查处理器架构：
# architecture=$(uname -m)
# echo -e '\E[32m'"Architecture :" $tecreset $architecture

# 检查内核：
# kernelrelease=$(uname -r)
# echo -e '\E[32m'"Kernel Release :" $tecreset $kernelrelease

# 检查外网IP：
internalip=$(hostname -I)
echo -e '\E[32m'"Internal IP :" $tecreset $internalip

# 检查内网IP：
externalip=$(curl -s ipecho.net/plain;echo)
echo -e '\E[32m'"External IP : $tecreset "$externalip

# 检查DNS：
nameservers=$(cat /etc/resolv.conf | sed '1 d' | awk '{print $2}')
echo -e '\E[32m'"Name Servers :" $tecreset $nameservers 

# 检查RAM使用情况：
free -h | grep -v + > /tmp/ramcache
echo -e '\E[32m'"Ram Usages :" $tecreset
# 检查SWAP使用情况：
cat /tmp/ramcache | grep -v "Swap"
echo -e '\E[32m'"Swap Usages :" $tecreset
cat /tmp/ramcache | grep -v "Mem"

# 检查磁盘使用情况：
echo -e '\E[32m'"Disk Usages :" $tecreset 
df -h
# 检查负载平均值：
loadaverage=$(top -n 1 -b | grep "load average:" | awk '{print $10 $11 $12}')
echo -e '\E[32m'"Load Average :" $tecreset $loadaverage

# 检查系统更新时间：
tecuptime=$(uptime | awk '{print $3,$4}' | cut -f1 -d,)
echo -e '\E[32m'"System Uptime Days/(HH:MM) :" $tecreset $tecuptime

# 重置变量：
unset tecreset os architecture kernelrelease internalip externalip nameserver loadaverage

# 移除临时文件：
rm /tmp/osrelease /tmp/ramcache
}
fi
shift $(($OPTIND -1))
