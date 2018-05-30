> ubuntu 登录不进去
	因为16.04升级之后，nivdia驱动需要更新
	apt-get install nivdia-384

> /var/run/docker.sock: connect: permission denied
sudo chmod 666 /var/run/docker.sock

> nginx add log
在/etc/nginx/nginx.conf添加
log_format main '$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent" "$http_x_forwarded_for"';
error_log logs/error.log  error;
access_log logs/access.log  main;

> add aliyun source 14.04
```
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
sudo vim /etc/apt/sources.list
deb http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multivers
```

```
deb http://mirrors.aliyun.com/ubuntu/ xenial main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ xenial-proposed main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ xenial main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ xenial-proposed main restricted universe multiverse
deb-src http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse
```
> 查看cuda信息
http://blog.csdn.net/dengheCSDN/article/details/78190710

> 查看mysql docker 容器参数
sudo docker run -it --rm storage-shshukun:5050/mysql:latest --verbose --help

> apt-get: relocation error: /usr/lib/x86_64-linux-gnu/libapt-pkg.so.5.0: symbol _ZNKSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE7compareERKS4_, version GLIBCXX_3.4.21 not defined in file libstdc++.so.6 with link time reference
应该是由于从14.04升级到16.04过程中出错，需要安装对应的包及其依赖，详见：
https://askubuntu.com/questions/777803/apt-relocation-error-version-glibcxx-3-4-21-not-defined-in-file-libstdc-so-6

> ubuntu 16.04 安装步骤
- 安装net-tools: apt-get install net-tools
- 安装16.04 server版本，因为desktop版本安装一直有问题， 安装桌面:sudo apt install ubuntu-gnome-desktop
- 磁盘挂载
- 配置阿里源
- 安装gcc: sudo apt install gcc
- 安装nvidia驱动： http://blog.csdn.net/Artprog/article/details/54755218
sudo apt-cache search nvidia | grep 384
sudo apt-get install nvidia-384
- 安装cuda: https://developer.nvidia.com/cuda-80-ga2-download-archive
http://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#system-requirements
`sudo dpkg -i cuda-repo-ubuntu1604_8.0.61-1_amd64.deb`
`sudo apt-get update`
`sudo apt-get install cuda`
驱动下载： http://www.nvidia.cn/Download/index.aspx?lang=cn
 
