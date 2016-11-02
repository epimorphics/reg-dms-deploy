#!/bin/bash
# Full update - assumes update testing on some dev/test machine 

set -o errexit

[[ $# = 1 ]] || { echo "Internal error calling $0, expected server address" 1>&2 ; exit 1 ; }

readonly SERVER="$1"
readonly IP=$( jq -r .address "$SERVER/config.json" )

. /opt/dms/conf/scripts/config.sh

# Complete update
APT_FLAGS='-o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -q -y'
#ssh -t -t $SSH_FLAGS -i $AWS_KEY -l ubuntu $IP sudo apt-get -y -q update
ssh -t -t $SSH_FLAGS -i $AWS_KEY -l ubuntu $IP sudo DEBIAN_FRONTEND=noninteractive apt-get $APT_FLAGS dist-upgrade
ssh -t -t $SSH_FLAGS -i $AWS_KEY -l ubuntu $IP sudo apt-get $APT_FLAGS autoclean
ssh -t -t $SSH_FLAGS -i $AWS_KEY -l ubuntu $IP sudo DEBIAN_FRONTEND=noninteractive apt-get $APT_FLAGS autoremove

# Force a reboot to install any dist upgrades
echo rebooting server
ssh -t -t $SSH_FLAGS -i $AWS_KEY -l ubuntu $IP sudo shutdown -r +1

# Wait for machine to come up again
sleep 180s
ssh -t -t $SSH_FLAGS -i $AWS_KEY -l ubuntu $IP echo "Server up" || ssh -t -t $SSH_FLAGS -i $AWS_KEY -l ubuntu $IP echo "Server up (2nd try)"

# Good luck pause to allow services to start as well
sleep 5s
