#!/bin/bash
echo "token started"
token_url='https://z-cwp-int.us.auth0.com/oauth/token'
client_id="KM9TPNvqLuQ06OV1pL7GMsrs3ydglzHu"
client_secret="2fevB95DNUBpPw-FKI-e2Fo7EED1aaMMkrMg1FzmhXrqDyOouR3jqCxbx_GpoXxQ"
download_url="https://int.api.zscwp.io/iac/onboarding/v1/cli/download?platform=Linux&arch=x86_64"
api_host="https://int.api.zscwp.io"
auth0_host="https://z-cwp-int.us.auth0.com"
$audience="https://api.zscwp.io/iac"
abc=$(curl --location --request POST $token_url  --header 'Content-Type: application/json' --data-raw '{ "audience" : $audience, "grant_type" : "client_credentials", "client_id" : $client_id, "client_secret" : $client_secret}')
echo $abc
echo "token call done"
regex_hint=access_token
[[ $abc =~ $regex_hint\":\"(.+)\",\"expires_in\" ]]
token=${BASH_REMATCH[1]}
echo $token
$(curl --location --request GET $download_url \
--header "Authorization: Bearer $token" \
--header 'Content-Type: application/json' \
--data-raw '{
    "platform": "Linux",
    "arch": "x86_64"
}' --output zscanner_binary.tar.gz)
echo "binary downloaded"
$(tar -xf zscanner_binary.tar.gz)
echo "retrieved zscanner"
$(sudo install zscanner /usr/local/bin && rm zscanner)
echo "check zscanner"
zscanner version
zscanner config list -a
zscanner config add -k custom_region -v "{\"host\":\"$api_host\",\"auth\":{\"host\":\"$auth0_host\",\"clientId\":\"$client_id\",\"scope\":\"offline_access profile\",\"audience\":\"$audience\"}}"
zscanner config list -a
zscanner logout
checkLogin=`zscanner login cc --client-id $client_id --client-secret $client_secret -r CUSTOM`
loginString='Logged in as system'
if [ "$checkLogin" == "$loginString" ]
then
  echo "successfully login to system"
else
  echo "Failed to login to system"
fi
zscanner scan -d .
if [ $? == 0 ]
then
  echo "Scan passed and no violations"
else
  echo "Scan Violations reported"
  exit 1
fi
