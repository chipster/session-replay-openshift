#oc process -f templates/session-replay.yaml | oc apply -f -

PASSWORD=""
APP_DOMAIN="rahti-int-app.csc.fi"

oc process -f templates/images-and-pvcs.yaml \
  -p DOCKERFILE_BASE="$(cat dockerfiles/base/Dockerfile | jq -s -R .)" \
  -p DOCKERFILE_SESSION_REPLAY="$(cat dockerfiles/session-replay/Dockerfile | jq -s -R .)" \
  -p DOCKERFILE_APACHE="$(cat dockerfiles/apache/Dockerfile | jq -s -R .)" \
  -p PROJECT="$(oc project -q)" \
  -p APP_DOMAIN="$APP_DOMAIN" \
  | oc apply -f -

oc start-build base --follow
oc start-build session-replay --follow
oc start-build apache --follow


bash run-test-set.bash $PASSWORD 1 availability
bash schedule-cronjob.bash $PASSWORD 1 availability '* * * * *'

# if you want to copy a local session
cat ~/Downloads/replay-test/io-test | oc rsh dc/base bash -c "cat - > test-sessions/io-test"

# or download all session from pouta (use the rsync script in the ci server to get them there)
oc rsh dc/apache bash -c "cd /var/www/html/test-sessions; bash"
wget -r -np --cut-dirs=2 -nH -R index.html http://vm0151.kaj.pouta.csc.fi/artefacts/test-sessions/
rm */index.html*

# if example sessions are in the old unsupported format, they can be updated using the old CLI client:

wget https://chipster.csc.fi/chipster-cli.bash

for f in tools-hourly/*; do
  dir=$(dirname $f)
  file=$(basename $f)
  mkdir -p ${dir}2
  bash chipster-cli.bash -u demo -p $PASSWORD clear-session
  echo "open $dir/$file"
  bash chipster-cli.bash -u demo -p $PASSWORD open-session $dir/$file
  echo "save ${dir}2/$file"
  bash chipster-cli.bash -u demo -p $PASSWORD save-session ${dir}2/$file
done