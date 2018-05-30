#!/bin/bash

if [ $# -ne 1 ]; then
    echo -e "please enter pid, eg: $0 123"
    exit
else
    root=$1
fi

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

treekill $root