#!/bin/bash
set -e
function usage()
{
echo "usage: $0 <rundate>"
echo "eg: $0 2018-05-10"
exit
}

RUNDATE=$1
if [[ $# != 1 ]]; then
usage
fi

cd /home/devops1/sk/delivering-toolset/chd-ai/
python dotest.py $RUNDATE
cd /home/devops1/sk/medicalbrain-cta-srv/
export MEDICALBRAIN_CTA_S_CONFIG=./configs/station.yml
python manage.py refresh_meta --case_date=$RUNDATE

