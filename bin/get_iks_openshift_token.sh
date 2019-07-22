#!/usr/bin/env sh
####################
# A simple script to get token for talking
# kubernetes with openshift from IBM Cloud API key
# We assume we will find IC_API_KEY in env var

# This will mainly run in terraform container, so assume install command for now
INSTALL_CMD="apk install -q"

function check_deps() {
  test -f $(which jq) || ${INSTALL_CMD} jq
}

function parse_input() {
  eval "$(jq -r '@sh "export SERVER_URL=\(.server_url)"')"
}

function return_token() {
  TOKEN=$(curl -v -u apikey:${IC_API_KEY} "https://${SERVER_URL}/oauth/authorize?client_id=openshift-challenging-client&response_type=token" \
    -skv -H "X-CSRF-Token: xxx" --stderr - |  grep location: | sed -E 's/(.*)(access_token=)([^&]*)(&.*)/\3/')
  jq -n \
    --arg token "$TOKEN" \
    '{"token":$token}'
}
check_deps && \
parse_input && \
return_token
