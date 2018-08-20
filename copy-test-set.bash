#!/bin/bash

# Script for uploading the old zip test sessions to Chipster app

set -e

if [ -z $1 ]; then
  echo "Usage copy-test-set.bash TEST_SET"
  exit 1
fi

test_set="$1"

chipster="chipster-web-server/js/cli-client/src/chipster"
node="node-v8.11.3-linux-x64/bin/node"

echo "Current sessions in this test set on the server:"
node $chipster -q session list | grep ^$test_set/

echo "Going to delete the above sessions after 10 seconds (Press Ctrl + C to interrupt)..."

sleep 10

$node $chipster -q session list | grep ^$test_set/ | while read line; do
  name=$(echo "$line" | awk '{print $1}')
  id=$(echo "$line" | awk '{print $2}')
  
  echo "delete session name: $name id: $id"
  $node $chipster -q session delete $id
done

echo ""

for s in $(find ~/test-sessions/$test_set/*.zip); do
  name=$(basename $s .zip)
  echo Upload $s
  $node $chipster -q session upload $s --name $test_set/$name
done