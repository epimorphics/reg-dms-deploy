#!/bin/bash

readonly AMI_UBUNTU_EBS=ami-cda130ba        # ubuntu 14.04, 64bit, ebs root
readonly AMI_UBUNTU_INSTANCE=ami-3b69b84c   # ubuntu 14.04, 64bit, instance root
readonly AMI_UBUNTU_HVM=ami-c5bf2eb2        # ubuntu 14.04, 64bit, HVM (for use with t2)
readonly SG_BACK_END=sg-761ac813            # security group for lds-back-end
readonly SG_FRONT_END=sg-b815c7dd           # security group for lds-front-end
readonly VPC_PUBLIC_B=subnet-5b73601d       # public subnet for LDS VPC
readonly VPC_PUBLIC_C=subnet-345c8d51       # public subnet for LDS VPC
readonly VPC_PUBLIC=( $VPC_PUBLIC_B $VPC_PUBLIC_C )

readonly ELASTIC_IP="54.194.13.210"
readonly ELASTIC_IP_ALLOC="eipalloc-bed131db"
readonly MONITOR_NET_IF="eni-784d621d"
readonly AWS_DMS_ROLE="arn:aws:iam::853478862498:instance-profile/dms-automation"

readonly WORKER_ELASTIC_IP="54.171.103.135"
readonly WORKER_ELASTIC_IP_ALLOC="eipalloc-0ff5196a"
readonly AWS_DMS_WORKER_ROLENAME="dms-worker"
readonly AWS_DMS_WORKER_ROLE="arn:aws:iam::853478862498:instance-profile/dms-worker"
