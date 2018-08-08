#!/bin/bash

set -e

if [ -z "$4" ]; then
  echo "Usage: schedule-cronjob.bash PASSWORD PARALLEL_JOBS TEST_SET SCHEDULE"
  exit 1
fi

password="$1"
parallel="$2"
test_set="$3"
schedule="$4"
job_name="session-replay-cronjob-$test_set"

if oc get job $job_name -o name > /dev/null 2>&1; then
  oc delete job $job_name
fi

oc process -f templates/cronjob.yaml \
    -p SCHEDULE="$schedule" \
    -p NAME="$job_name" \
    -p PROJECT="$(oc project -q)" \
    -p USERNAME="demo" \
    -p PASSWORD="$password" \
    -p PARALLEL="$parallel" \
    -p SERVER="http://chipster.rahti-int-app.csc.fi" \
    -p PATH="/home/user/test-data/test-sessions/$test_set" \
    -p RESULTS="/home/user/test-data/results/$test_set" \
    | oc apply -f -
