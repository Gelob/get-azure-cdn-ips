#!/bin/bash

tenantid=""
clientid=""
clientsecret=""

#default is IPv4
version=4

if [ -z "$1" ]
then
  version=4
elif [ $1 -eq 6 ]
then
  version=6
fi

accesstoken=$(curl -s -X GET \
  https://login.microsoftonline.com/"$tenantid"/oauth2/v2.0/token \
  -H 'Accept: */*' \
  -H 'Cache-Control: no-cache' \
  -H 'Connection: keep-alive' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -H 'Host: login.microsoftonline.com' \
  -H 'accept-encoding: gzip, deflate' \
  -H 'cache-control: no-cache' \
  -d 'grant_type=client_credentials&client_id='"$clientid"'&scope=https%3A%2F%2Fmanagement.core.windows.net%2F.default&client_secret='"$clientsecret"'' | jq -r .access_token)

json=$(curl -s 'https://management.azure.com/providers/Microsoft.Cdn/edgenodes?api-version=2017-10-12' -H "Authorization: Bearer $accesstoken")

echo $json | jq -r '.value[].properties.ipAddressGroups[].ipv'"$version"'Addresses[] | "\(.baseIpAddress)/\(.prefixLength)"' | sort | uniq
