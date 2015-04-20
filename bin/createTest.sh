#!/bin/bash
# Allocate a new instance for generic script testing
#   - assumes run from root of dms-deploy
set -o errexit

. bin/lib/config.sh
. bin/lib/lib.sh
CheckInstalls

serverDir="test-deployment"
NAME="dms-test"
FULL_NAME="dms-test"
CHEF_ROLE=TBD

mkdir -p $serverDir

#AWS_EBS=5
AWS_INSTANCE_STORE=yes
AWS_INSTANCE_TYPE=m3.medium
AWS_AMI=ami-096cbd7e
AWS_SG=$SG_FRONT_END
VPC=$VPC_PUBLIC_C
AllocateServer $serverDir
InstallChefSolo "$serverDir" chef