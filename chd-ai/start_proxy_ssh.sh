#!/bin/bash

__ScriptName="start_proxy_ssh.sh"

#-----------------------------------------------------------------------  
# FUNCTION: usage  
# DESCRIPTION:  Display usage information.  
#-----------------------------------------------------------------------  
usage() {
  cat << EOT
    Usage :  ${__ScriptName} [OPTION] ...
      Build app from given options.
      
    Required Options:  
      --help											display help message
      --local-ssh-port=LOCAL_SSH_PORT    				local ssh port
      --remote-proxy-port=REMOTE_PROXY_PORT				remote proxy port
      --remote-ssh-port=REMOTE_SSH_PORT                 remote ssh port


      Exit status:
      0   if OK,
      !=0 if serious problems.
      
    Example:
      1) Use long options to build app:
        $ sudo $__ScriptName --local-ssh-port=123 --remote-proxy-port=123 --remote-ssh-port=123
EOT
}

LOCAL_SSH_PORT=
REMOTE_PROXY_PORT=
REMOTE_SSH_PORT=

# parse options:  
RET=`getopt -o ha:b:c: -a -l help,local-ssh-port:,remote-proxy-port:,remote-ssh-port: -n 'ERROR' -- "$@"`

if [ $? != 0 ] ; then echo "$__ScriptName exited with doing nothing." >&2 ; exit 1 ; fi

# Note the quotes around $RET: they are essential!
eval set -- "$RET"

# set option values
while true; do
    case "$1" in
        -h|--help ) usage; exit 1;;
 
        -a|--local-ssh-port ) LOCAL_SSH_PORT=$2
        echo "local ssh port is: $REMOTE_PROXY_PORT"
        shift 2 ;;
 
        -b|--remote-proxy-port ) REMOTE_PROXY_PORT=$2
        echo "remote proxy port is: $REMOTE_PROXY_PORT"
        shift 2 ;;
 
        -c|--remote-ssh-port ) REMOTE_SSH_PORT=$2
        echo "remote ssh port is: $REMOTE_SSH_PORT"
        shift 2 ;;
 
        -- ) shift; break ;;
        * ) echo "$1 is not option" ; exit 1 ;;
	esac
done

if [[ -z $LOCAL_SSH_PORT ]]; then
  usage
  exit 1
fi

if [[ -z $REMOTE_PROXY_PORT ]]; then
  usage
  exit 1
fi

if [[ -z $REMOTE_SSH_PORT ]]; then
  usage
  exit 1
fi

ssh -f -N -R $REMOTE_PROXY_PORT:localhost:$LOCAL_SSH_PORT -p $REMOTE_SSH_PORT devops1@103.211.47.132