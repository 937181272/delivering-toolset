#!/bin/bash
set -e

function usage()
{
	echo "usage: $0 <SSH_PORT> <USERNAME> <PASSWORD> <RELEASE_SERVER_PWD> <RESTART> <SSH_REMOTE_PORT>"
	echo "eg: $0 22 testuser testpwd testpwd false"
	exit
}

function treekill()
{
    local father=$1
    # children
    childs=`ps -ef | awk -v father=$father 'BEGIN{ ORS=" "; } $3==father{ print $2; }'`
    if [ ${#childs[@]} -ne 0 ]; then
        for child in ${childs[*]}
        do
            treekill $child
        done
    fi
    # father
    kill -9 $father
}

function update_cfg_start()
{
	f_auth=$1
	f_ssh_port=$2
	f_ssh_remote_port=$3
	echo 'update config file'
	sed -i '/auth_token/'d ngrok.yml
	sed -i "3iauth_token: $f_auth" ngrok.yml
	sed -i '/tcp/'d ngrok.yml
	sed -i '/remote_port/'d ngrok.yml
	echo "      tcp: $f_ssh_port" >> ngrok.yml
	echo "    remote_port: $f_ssh_remote_port" >> ngrok.yml
	nohup ./ngrok -config=ngrok.yml -log=ngrok.log start ssh &
}

if [[ $# != 6 ]]; then
	usage
fi

SSH_PORT=$1
USERNAME=$2
PASSWORD=$3
RELEASE_SERVER_PWD=$4
RESTART=$5
SSH_REMOTE_PORT=$6

AUTH=$USERNAME:$PASSWORD
RELEASE_SERVER_USER=devops1

WORKSPACE=/home/devops1/sk
cd $WORKSPACE
if [ ! -d "ngrok-client-linux" ];then
	wget --http-user=$RELEASE_SERVER_USER --http-password=$RELEASE_SERVER_PWD http://103.211.47.132:99/ngrok-client-linux/1.7.0/ngrok-client-linux-1.7.0.tar.gz
	tar -xzvf ngrok-client-linux-1.7.0.tar.gz
fi

cd ngrok-client-linux
PID=$(ps -ef | grep "./ngrok -config=ngrok.yml" | grep -v grep | awk '{print $2}')
if [[ ! -z $PID ]]; then
	echo 'ngrok is already running, kill it'
	if [[ $RESTART == "true" ]]; then
		treekill $PID
		update_cfg_start $AUTH $SSH_PORT $SSH_REMOTE_PORT
	else
		echo 'ngrok is already running, do not kill'
	fi
else
	update_cfg_start $AUTH $SSH_PORT $SSH_REMOTE_PORT
fi