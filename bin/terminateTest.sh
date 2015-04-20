#!/bin/bash
# Delete the test instance
#   - assumes run from root of dms-deploy
set -o errexit

. bin/lib/config.sh
. bin/lib/lib.sh
CheckInstalls

serverDir="test-deployment"

readonly instanceID=$(jq -r ".Instances[0].InstanceId" < $serverDir/aws-instance.json)
echo "Terminating $serverDir"
state=$(aws ec2 terminate-instances --instance-ids $instanceID | jq -r ".TerminatingInstances[0].CurrentState.Name")
echo "Instance is $state"
