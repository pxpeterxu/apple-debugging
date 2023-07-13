#!/bin/sh
set -ex

#
# This script tries to get the client-scoped transfer identifier
#


while [ $# -gt 0 ]; do
  case $1 in
    --team-id) TEAM_ID="$2"; shift 2;;
    --client-id) CLIENT_ID="$2"; shift 2;;
    --key-id) KEY_ID="$2"; shift 2;;
    --private-key-file) PRIVATE_KEY_FILE="$2"; shift 2;;
    --transfer-sub) TRANSFER_SUB="$2"; shift 2;;
  esac
done

if [ -z "$TEAM_ID" ] || [ -z "$CLIENT_ID" ] || [ -z "$KEY_ID" ] || [ -z "$PRIVATE_KEY_FILE" ] || [ -z "$TRANSFER_SUB" ]; then
cat <<'END'
Usage: bash getTransferIdentifier.sh --team-id TEAM_ID --client-id CLIENT_ID --key-id KEY_ID --private-key-file PRIVATE_KEY_FILE --transfer-sub TRANSFER_SUB'
Example: bash getTransferIdentifier.sh --team-id M2QQ82XT4F --client-id com.wanderlog.web --key-id 4VHS25M9Z5 --private-key-file privatekey.txt --transfer-sub 000000.r000cdcdd5e494baca075bffbed5775b8

Some arguments are missing: please check your command

END
exit 1
fi


npm install
JWT=$(node generateJWT.js "$CLIENT_ID" "$TEAM_ID" "$KEY_ID" "$PRIVATE_KEY_FILE")
echo
echo "Using client secret: $JWT"
echo

# Get an access token
# Based on https://developer.apple.com/documentation/sign_in_with_apple/bringing_new_apps_and_users_into_your_team
ACCESS_TOKEN=$(curl --no-progress-meter -X POST -d "grant_type=client_credentials&scope=user.migration&client_id=com.wanderlog.web&client_secret=$JWT" https://appleid.apple.com/auth/token | jq --raw-output '.access_token')

if [ -z "$ACCESS_TOKEN" ]; then
  echo 'Could not get valid access token: check the team ID, key ID, client ID, and private key'
  exit 1
fi

echo "Using access token $ACCESS_TOKEN"
echo

echo "Output from API:"
curl --no-progress-meter -X POST \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -d "client_id=com.wanderlog.web&client_secret=$JWT&transfer_sub=$TRANSFER_SUB" \
  https://appleid.apple.com/auth/usermigrationinfo


