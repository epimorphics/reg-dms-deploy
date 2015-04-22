#!/bin/bash
# Call data server to pull updated state from S3

set -o errexit

[[ $# = 2 ]] || { echo "Usage: duPublish serverDir" 1>&2 ; exit 1 ; }
serverDir="/var/opt/dms/$1/servers/$2"

. ./config.sh

IP=$( jq -r .address "$serverDir/config.json" )

echo "Calling dms-update on $serverDir"
ssh -t -t $SSH_FLAGS -i $AWS_KEY -l ubuntu $IP /bin/bash /usr/local/bin/dms-update --perform
