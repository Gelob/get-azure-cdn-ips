#!/bin/bash

tenantid=""
clientid=""
clientsecret=""
installdir="/opt/azure"
gitdir="/opt/azure/getips"

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

if [ -z "$accesstoken" ]; then
  echo "$(date) - Error: Couldn't get an access token" >> $installdir/getips.log
  exit 1
fi

json=$(curl -s -o $gitdir/edgenodes.json 'https://management.azure.com/providers/Microsoft.Cdn/edgenodes?api-version=2017-10-12' -H "Authorization: Bearer $accesstoken" && cat $gitdir/edgenodes.json)

if [[ $json == *"error"* ]]; then
  echo "$(date) - Error: - "$json >> $installdir/getips.log
  exit 1
elif [ -z "$json" ]; then
  echo "$(date) - Error: JSON response was blank" >> $installdir/getips.log
  exit 1
fi

#write ipv4 and ipv6 files
echo $json | jq -r '.value[].properties.ipAddressGroups[].ipv4Addresses[] | "\(.baseIpAddress)/\(.prefixLength)"' | sort | uniq > $gitdir/edgenodes-ipv4.txt
echo $json | jq -r '.value[].properties.ipAddressGroups[].ipv6Addresses[] | "\(.baseIpAddress)/\(.prefixLength)"' | sort | uniq > $gitdir/edgenodes-ipv6.txt

#write date
echo $(date +"%m/%d/%Y") > $gitdir/lastrun

IP1=$(head -1 $gitdir/edgenodes-ipv4.txt)
IP2=$(tail -1 $gitdir/edgenodes-ipv4.txt)
if [[ $IP1 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\/[0-9][0-9]$ ]]; then
  :
  if [[ $IP2 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\/[0-9][0-9]$ ]]; then
    cd $gitdir/
    git add edgenodes.json
    git add edgenodes-ipv4.txt
    git add edgenodes-ipv6.txt
    git add lastrun
    git commit -m "Daily Update"
    git push -u origin master
  else
    echo "$(date) - Error: Couldn't validate IPv4 IPs, aborting" >> $installdir/getips.log
    exit 1
  fi
fi
