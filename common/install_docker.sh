#!/usr/bin/env bash

# remove old version
#apt-get remove docker docker-engine docker.io

# Install docker ce
apt-get update

tmp_str=`lsb_release -r | grep '16.04'`
if [ -z "$tmp_str" ];then
    apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual
fi

apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

# offical
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
#apt-key fingerprint 0EBFCD88
#add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
#apt-get update
#apt-cache madison docker-ce
#apt-get -y install docker-ce=17.12.0~ce-0~ubuntu

# aliyun mirror install
curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
apt-get -y update
apt-get -y install docker-ce

# install nvidia docker
# Add the package repositories
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | \
  sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/ubuntu16.04/amd64/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update

# Install nvidia-docker2 and reload the Docker daemon configuration
sudo apt-get install -y nvidia-docker2
sudo pkill -SIGHUP dockerd
