#!/bin/bash

set -e

if [ -z "$3" ]; then
  echo "Usage: run-test-set.bash PASSWORD PARALLEL_JOBS TEST_SET"
  exit 1
fi

password="$1"
parallel="$2"
test_set="$3"
job_name="session-replay-job-$test_set"

if oc get job $job_name -o name > /dev/null 2>&1; then
  oc delete job $job_name
fi

oc process -f templates/job.yaml \
    -p NAME="$job_name" \
    -p PROJECT="$(oc project -q)" \
    -p USERNAME="replay_test" \
    -p PASSWORD="$password" \
    -p PARALLEL="$parallel" \
    -p SERVER="http://chipster.rahti-int-app.csc.fi" \
    -p TEST_SET="$test_set" \
    -p RESULTS="/home/user/test-data/results/$test_set" \
    | oc apply -f -

while ! oc logs -f $(oc describe job $job_name | grep "Created pod:" | cut -d ":" -f 2); do
  sleep 2
done

