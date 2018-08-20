#!/bin/bash

set -e

if [ -z $2 ]; then
  echo "Usage update-zip-session-format.bash USERNAME PASSWORD SET_SET"
  exit 1
fi

username="$1"
password="$2"
test_set="$3"

sessions="/home/csc/chipster/test-sessions"

wget https://chipster.csc.fi/chipster-cli.bash

for f in $sessions/$test_set/*.zip; do
  dir=$(dirname $f)
  file=$(basename $f)
  mkdir -p ${dir}2
  bash chipster-cli.bash -u $username -p $password clear-session
  echo "open $dir/$file"
  bash chipster-cli.bash -u $username -p $password open-session $dir/$file
  echo "save ${dir}2/$file"
  bash chipster-cli.bash -u $username -p $password save-session ${dir}2/$file
done