#!/bin/bash

set -e

if [ -z "$4" ]; then
  echo "Usage: schedule-cronjob.bash SERVER PASSWORD TEST_SET SCHEDULE"
  exit 1
fi

server="$1"
password="$2"
test_set="$3"
schedule="$4"
image="$5"

server_name="$(echo "$server" | sed s*https://** | sed s/\\./-/g)"

job_name="cronjob-$test_set-$server_name"

if oc get cronjob $job_name -o name > /dev/null 2>&1; then
  oc delete cronjob $job_name
fi

oc process -f templates/cronjob.yaml \
    -p SCHEDULE="$schedule" \
    -p NAME="$job_name" \
    -p PROJECT="$(oc project -q)" \
    -p USERNAME="replay_test" \
    -p PASSWORD="$password" \
    -p PARALLEL="1" \
    -p SERVER="$server" \
    -p TEST_SET="$test_set" \
    -p RESULTS="/home/user/test-data/results/$test_set-$server_name" \
    -p IMAGE="$image" \
    | oc apply -f -
