#!/bin/bash

echo 'date format: 2018-05-22'
python /home/devops1/sk/medicalbrain-cta-srv/manage.py refresh_meta --case_date=$1