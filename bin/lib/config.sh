# AWS Configuration information

# VPC configuration
readonly SG_BACK_END=sg-0ce5166b            # security group for dms-backend
readonly SG_FRONT_END=sg-fae5169d           # security group for dms-frontend
readonly SG_CONTROL=sg-b6e615d1             # security group for dms-control

readonly VPC_PUBLIC_B=subnet-c4474f9d       # public subnet for DMS VPC
readonly VPC_PUBLIC_C=subnet-5950983d       # public subnet for DMS VPC
readonly VPC_PUBLIC=( $VPC_PUBLIC_B $VPC_PUBLIC_C )

# Interfaces
readonly ELASTIC_IP="52.49.130.89"
readonly ELASTIC_IP_ALLOC="eipalloc-1ed5bc7b"
readonly MONITOR_NET_IF="eni-9f7a38e6"

# The automation instance role
readonly AWS_DMS_ROLE="arn:aws:iam::359429338055:instance-profile/dms-automation"

# Location where the configuration state should be preserved
readonly S3_BUCKET="s3://reg-dms-deploy"
readonly S3_STATE="$S3_BUCKET/dms-state"

# Other AWS defaults
export AWS_DEFAULT_REGION=eu-west-1
readonly AMI_UBUNTU_EBS=ami-537afa20        # ubuntu 14.04, 64bit, ebs root
readonly AMI_UBUNTU_INSTANCE=ami-8470f0f7   # ubuntu 14.04, 64bit, instance root
readonly AMI_UBUNTU_HVM=ami-6077f713        # ubuntu 14.04, 64bit, HVM (for use with t2)

readonly PREFIX=reg
export AWS_DEFAULT_PROFILE=reg

# Nagrestconf location, normally on DMS controller machine
readonly NRC_HOST=127.0.0.1                 

# Suppress SSH known key checking
export SSH_FLAGS="-q -o BatchMode=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

# Location of AWS access key
readonly AWS_KEY=~/.ssh/reg.pem

