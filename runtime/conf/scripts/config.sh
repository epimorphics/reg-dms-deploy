# AWS Configuration information

# VPC configuration
readonly SG_BACK_END=sg-b6a5f3d3            # security group for dms-backend
readonly SG_FRONT_END=sg-61a2f404           # security group for dms-frontend
readonly SG_CONTROL=sg-eea5f38b             # security group for dms-control

readonly VPC_PUBLIC_B=subnet-4bf99d2e       # public subnet for DMS VPC
readonly VPC_PUBLIC_C=subnet-5db9352a       # public subnet for DMS VPC
readonly VPC_PUBLIC=( $VPC_PUBLIC_B $VPC_PUBLIC_C )

# Interfaces
readonly ELASTIC_IP="52.16.138.169"         # Elastic IP address for the controller
readonly ELASTIC_IP_ALLOC="eipalloc-57aa5232"  # The allocation ID associated with the Elastic IP

readonly MONITOR_NET_IF="eni-76e98f00"      # The elastic network interface attached to the controller

# The automation instance role
readonly AWS_DMS_ROLE="arn:aws:iam::828737851284:instance-profile/dms-automation"

# Location where the configuration state should be preserved
readonly S3_BUCKET="s3://ts-dms-deploy"
readonly S3_STATE="$S3_BUCKET/ts-state"

# Other AWS defaults
export AWS_DEFAULT_REGION=eu-west-1
readonly AMI_UBUNTU_EBS=ami-cda130ba        # ubuntu 14.04, 64bit, ebs root
readonly AMI_UBUNTU_INSTANCE=ami-3b69b84c   # ubuntu 14.04, 64bit, instance root
readonly AMI_UBUNTU_HVM=ami-c5bf2eb2        # ubuntu 14.04, 64bit, HVM (for use with t2)

readonly PREFIX=ts
# export AWS_DEFAULT_PROFILE=ts

# Nagrestconf location, normally on DMS controller machine
readonly NRC_HOST=127.0.0.1                 

# Suppress SSH known key checking
export SSH_FLAGS="-q -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

# Location of AWS access key
readonly AWS_KEY=~/.ssh/ts.pem

