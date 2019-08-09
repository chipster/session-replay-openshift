#oc process -f templates/session-replay.yaml | oc apply -f -

PASSWORD="$(cat ../chipster-private/confs/chipster-all/users | grep benchmark | cut -d ":" -f 2)"
APP_DOMAIN="rahti-int-app.csc.fi"

oc process -f templates/images-and-pvcs.yaml \
  -p DOCKERFILE_BASE="$(cat dockerfiles/base/Dockerfile | jq -s -R .)" \
  -p DOCKERFILE_SESSION_REPLAY="$(cat dockerfiles/session-replay/Dockerfile | jq -s -R .)" \
  -p DOCKERFILE_APACHE="$(cat dockerfiles/apache/Dockerfile | jq -s -R .)" \
  -p PROJECT="$(oc project -q)" \
  -p APP_DOMAIN="$APP_DOMAIN" \
  | oc apply -f -
  
PASSWORD="$(cat ../chipster-private/confs/chipster-all/users | grep benchmark | cut -d ":" -f 2)"
APP_DOMAIN="rahti-int-app.csc.fi"

oc process -f templates/images-master.yaml \
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
bash schedule-cronjob.bash https://chipster.rahtiapp.fi $PASSWORD availability '*/5 * * * *' session-replay
bash schedule-cronjob.bash https://chipster.rahtiapp.fi $PASSWORD tools-hourly2 '12 * * * *' session-replay
bash schedule-cronjob.bash https://chipster.rahtiapp.fi $PASSWORD tools-daily2 '32 6 * * *' session-replay

# if you want to copy a local session
cat ~/Downloads/replay-test/io-test | oc rsh dc/base bash -c "cat - > test-sessions/io-test"

# or download all session from pouta (use the rsync script in the ci server to get them there)
oc rsh dc/apache bash -c "cd /var/www/html/test-sessions; bash"
wget -r -np --cut-dirs=2 -nH -R index.html http://vm0151.kaj.pouta.csc.fi/artefacts/test-sessions/
rm */index.html*

# in case you want to delete all sessions of a user:
# first, check that your are logged in as a correct user
# node src/chipster session list
# node src/chipster -q session list | awk '{print $2}' | parallel -P 10 node src/chipster session delete