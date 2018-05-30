#!/bin/bash

function usage()
{
	echo "usage: $0 <computer> <secret> <restart>"
	echo "eg: $0 zdyfy-001 8343ca6839af4df0b8d4fbc4355c0c6fdc4ee9176db4cf4244 false"
	exit
}

function treekill()
{
	local father=$1
	if [[ -z $father ]]; then
		echo "app is already stopped."
		exit 0
	else
		childs=`ps -ef | awk -v father=$father 'BEGIN{ ORS=" "; } $3==father{ print $2; }'`
		if [ ${#childs[@]} -ne 0 ]; then
			for child in ${childs[*]}
			do
			    treekill $child
			done
		fi
		kill -9 $father
	fi
}

if [[ $# != 3 ]]; then
	usage
fi

WORKSPACE=/home/devops1/sk
if [[ ! -d $WORKSPACE/jenkins ]]; then
	mkdir -p $WORKSPACE/jenkins
fi
cd $WORKSPACE/jenkins

#computer example: zdyfy-001
computer=$1
#secret example: 8343ca6839af4df0b8d4fbc4355c0c6fdc4ee9176db4cf42
secret=$2
restart=$3

if [ ! -f "agent.jar" ];then
	echo 'agent is not existing, download...'
	wget http://103.211.47.132:8182/jnlpJars/agent.jar
fi

PID=$(ps -ef | grep "java -jar agent.jar" | grep -v grep | awk '{print $2}')
if [[ ! -z $PID ]]; then
	if [[ $restart == "true" ]]; then
		echo 'jenkins slave is already running, kill it'
		treekill $PID
		nohup java -jar agent.jar -jnlpUrl http://103.211.47.132:8182/computer/$computer/slave-agent.jnlp -secret $secret -workDir "/tmp/jenkins_home" &
	else
		echo 'jenkins slave is already running, will not kill'
	fi
else
	nohup java -jar agent.jar -jnlpUrl http://103.211.47.132:8182/computer/$computer/slave-agent.jnlp -secret $secret -workDir "/tmp/jenkins_home" &
fi