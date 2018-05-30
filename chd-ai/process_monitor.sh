#!/bin/bash

PID=$(ps -ef | grep "python manage.py run" | grep -v grep | awk '{print $2}')

if [[ -z $PID ]]; then
	exit 1
fi