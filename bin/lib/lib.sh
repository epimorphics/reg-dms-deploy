#!/bin/bash
# Library of utilities used in DMS automation

. bin/lib/config.sh

# Wait until an aws operation reaches a target state
# WaitFor $command $jqpattern $target
WaitFor() {
	[[ $# = 3 ]] || { echo "Internal error calling wait-for" 1>&2 ; exit 99 ; }
	local cmd=$1
	local pattern=$2
	local target=$3
	local loop=1
	while [[ $loop -le 300 ]]
	do
		STATE=`$cmd | jq -r $pattern`
		echo "State is: $STATE"
		if [[ $STATE == $target ]]; then
			return 0
		fi
		sleep 3
		loop=$(( $loop + 1 ))
	done
	return 1
}

# Check required programs are installed
CheckInstalls() {
	command -v aws >/dev/null 2>&1 || { echo >&2 "Need aws installed: http://aws.amazon.com/cli/.  Aborting."; exit 1; }
	command -v jq >/dev/null 2>&1 || { echo >&2 "Need jq installed: http://stedolan.github.io/jq/download/.  Aborting."; exit 1; }
}

# Pick a random availability zone - not used in a VPC setting, pick subnet instead
PickZone() {
	aws ec2 describe-availability-zones --filters Name=state,Values=available | jq -r ".AvailabilityZones[$(( $RANDOM % 3 ))].ZoneName"
}

# Shell based provisioning, syncs source area then roots bootstrap.sh script
# ShellProvision $serverDir $sourceDir
ShellProvision() {
	[[ $# = 2 ]] || { echo "Internal error calling ShellProvision" 1>&2 ; exit 99 ; }
	local server=$1
	local source=$2
    local boot=$(basename $source)
	local IP=$(jq -r ".Instances[0].PublicDnsName" < $server/aws-instance.json)

	echo " - syncing provisioning data to $IP"
	rsync -avz -e "ssh $SSH_FLAGS -i $AWS_KEY"  --rsync-path="sudo rsync" $source "ubuntu@$IP:/dmsprovision/"
	echo " - running provisioning script $boot from source $source"
	ssh -4 -t -t -i $AWS_KEY -l ubuntu $IP "sudo sh /dmsprovision/$boot"
}

# Wait for ssh connection to become available on the aws instance
#    WaitForSsh  $serverDir
WaitForSsh() {
	[[ $# = 1 ]] || { echo "Internal error calling WaitForSsh" 1>&2 ; exit 99 ; }
	local server=$1
	local IP=$(jq -r ".Instances[0].PublicDnsName" < $server/aws-instance.json)
	local loop=1
	while [[ $loop -le 10 ]]
	do
		if ssh $SSH_FLAGS -i $AWS_KEY -l ubuntu $IP  "echo ssh up"; then
			return 0
		fi
		sleep 8
		loop=$(( $loop + 1 ))
	done
	echo "ssh access to instance failed" 1>&2
	return 1
}

# Compute AWS block-device-mappings from environment variables 
#     AWS_INSTANCE_STORE (yes or missing)
#     AWS_EBS (size in Gb)
BlockDeviceMappings() {
	local MAPPING=""
	if [[ $AWS_INSTANCE_STORE == "yes" ]] ; then
		MAPPING='{"DeviceName":"/dev/sdg","VirtualName":"ephemeral0"}'
	fi
	if [[ $AWS_EBS ]] ; then
		local EBS_MAPPING="{\"DeviceName\":\"/dev/sdf\",\"Ebs\":{\"VolumeSize\":$AWS_EBS,\"DeleteOnTermination\":false,\"VolumeType\":\"gp2\"}}"
		if [[ -z $MAPPING ]] ; then
			MAPPING="--block-device-mappings [$EBS_MAPPING]"
		else
			MAPPING="--block-device-mappings [$MAPPING,$EBS_MAPPING]"
		fi
    else
        MAPPING="--block-device-mappings [$MAPPING]"
	fi
	echo $MAPPING
}

# Allocate and AWS server and bootstrap it
# Arguments:
#    AllocateServer infoDir
# Environment settings:
#    FULL_NAME                full, unique name for the server
#    AWS_INSTANCE_TYPE        instance type to create
#    AWS_AMI                  AMI to use
#    AWS_SG                   security group(s)
#    AWS_INSTANCE_STORE=yes   allocate an instance store to ephemeral0
#    AWS_EBS=10               allocate an EBS of the given size 
#    AWS_IAM_ROLE_ARN         optional IAM role
#    AWS_IAM_ROLE_NAME        optional IAM role
#    VPC                      optional VPC subnet-id
#    AWS_EXTRA                optional additional flags to run-instances command


AllocateServer() {
	[[ $# = 1 ]] || { echo "Internal error calling AllocateServer" 1>&2 ; exit 1 ; }
    local serverDir=$1

	# Check if there is already an allocated server here
	if [[ -f $serverDir/aws-instance.json ]]; then
		echo "Server already exists, assuming this is a retry and continuing to wait for server to be ready"
		instanceID=$( jq -r '.Instances[0].InstanceId' < $serverDir/aws-instance.json )
	else
        # Start the instance
        if [[ -z $VPC ]] ; then
            VPC="${VPC_PUBLIC[ $RANDOM % 2 ]}"
        fi

        local BD=$(BlockDeviceMappings)

        [[ $BD ]] && echo "Using block device mappings: $BD"

        local iamRole=""
        if [[ -n $AWS_IAM_ROLE_ARN ]] ; then
#        	iamRole="--iam-instance-profile Arn=$AWS_IAM_ROLE_ARN,Name=$AWS_IAM_ROLE_NAME"
        	iamRole="--iam-instance-profile Arn=$AWS_IAM_ROLE_ARN"
        	echo "Assigning IAM role $iamRole"
        fi

        aws ec2 run-instances --count 1 \
        --image-id "$AWS_AMI" \
        --instance-type "$AWS_INSTANCE_TYPE" \
        --security-group-ids $AWS_SG \
        --key-name "$PREFIX" \
        --associate-public-ip-address \
        --subnet-id "$VPC" \
        $iamRole \
        $BD $AWS_EXTRA > $serverDir/aws-instance.json

        instanceID=$( jq -r '.Instances[0].InstanceId' < $serverDir/aws-instance.json )
        echo "Creating instance $instanceID"
    fi

	# Wait for the instance to be up
	WaitFor "aws ec2 describe-instances --instance-ids $instanceID" ".Reservations[0].Instances[0].State.Name" "running" || { echo "Instance startup failed"; exit 1; }

	# Name it
	aws ec2 create-tags --resources $instanceID --tags "Key=Name,Value=$FULL_NAME" > /dev/null

	# Record up state of server and extract IP address for DMS use
	aws ec2 describe-instances --instance-ids $instanceID | jq .Reservations[0] > $serverDir/aws-instance.json

	#jq  "{ address: .Instances[0].PrivateIpAddress, private: .Instances[0].PrivateIpAddress, public: .Instances[0].PublicDnsName }" < $serverDir/aws-instance.json > $serverDir/config.json
	# WARNING: This is a temporary hack to allow test access to machines in public
	jq  "{ address: .Instances[0].PublicDnsName, private: .Instances[0].PrivateIpAddress, public: .Instances[0].PublicDnsName, name: \"$FULL_NAME\" }" < $serverDir/aws-instance.json > $serverDir/config.json

	# Label the attached storage - if any
	jq -r '.Instances[0].BlockDeviceMappings[].Ebs.VolumeId' < $serverDir/aws-instance.json | xargs aws ec2 create-tags --tags "Key=Name,Value=disk-$FULL_NAME"  --resources > /dev/null

	# Format the disk if necessary
	WaitForSsh $serverDir
	ShellProvision $serverDir provision/base/bootstrap.sh	
}

# Configure Chef on a newly allocated machines
# Arguments:
#    InstallChef infoDir
# Environment settings:
#    FULL_NAME                full, unique name for the server
#    CHEF_ENV     chef environment for the node
#    CHEF_ROLE    name of the top level role for this node
#    CHEF_PARAMS  optional additional chef parameters in json syntax
InstallChef() {
    [[ $# = 1 ]] || { echo "Internal error calling InstallChef" 1>&2 ; exit 1 ; }
    local serverDir=$1

    config="\"epi_server_base\":{\"system_name\":\"$FULL_NAME\"}"
    if [[ -n $CHEF_PARAMS ]] ; then
        config="$config,$CHEF_PARAMS"
    fi
    IP=$(jq -r ".Instances[0].PublicDnsName" < $serverDir/aws-instance.json)
    echo "Bootstrapping chef: env=${CHEF_ENV:-dms} role=$CHEF_ROLE config={$config}"
    knife bootstrap  -i $AWS_KEY -x ubuntu --sudo \
                -E "${CHEF_ENV:-dms}" -r "$CHEF_ROLE" \
                -j "{$config}" \
                -N $FULL_NAME "$IP" -F min --no-color \
                --bootstrap-version 11.14.6  # TODO make this configurable!
}

# Configure Chef Solo on a newly allocated machine
# Arguments:
#    InstallChefSolo infoDir chefDir
# Environment settings:
#    FULL_NAME                full, unique name for the server
#    CHEF_ROLE  name of the top level role for this instance
InstallChefSolo() {
	[[ $# = 2 ]] || { echo "Internal error calling InstallChefSolo" 1>&2 ; exit 1 ; }
    local serverDir=$1
    local chefDir=$2

    IP=$(jq -r ".Instances[0].PublicDnsName" < $serverDir/aws-instance.json)
    echo "Installing chef solo to $IP"
    knife solo prepare "ubuntu@$IP" -N "$FULL_NAME" --identity-file $AWS_KEY --yes  --no-color
    mv nodes/$FULL_NAME.json $serverDir/node-orig.json

	# Set up node file to correspond to a single top level role
	cat > $serverDir/node.json <<!!
{
    "run_list" : [ "role[$CHEF_ROLE]" ],
    "automatic" : { "ipaddress" : "$IP" },
    "epi_server_base": {
        "system_name": "$FULL_NAME"
    }
}
!!
}

# Assocate an elastic IP address with an instance (VPC version)
# Aguments:
#      AssociateIP serverDir ipallocation
AssociateIP() {
    [[ $# = 2 ]] || { echo "Internal error calling AssociateIP" 1>&2 ; exit 1 ; }
    local serverDir=$1
    local ipalloc=$2

    INSTANCEID=$(jq -r ".Instances[0].InstanceId" < $serverDir/aws-instance.json)
    aws ec2  associate-address --instance-id $INSTANCEID --allocation-id $ipalloc --allow-reassociation
}

# Assocate an elastic network interface with an instance (VPC version)
# Aguments:
#      AttachENI serverDir eni_ID
AttachENI() {
    [[ $# = 2 ]] || { echo "Internal error calling AttachENI" 1>&2 ; exit 1 ; }
    local serverDir=$1
    local eni=$2

    INSTANCEID=$(jq -r ".Instances[0].InstanceId" < $serverDir/aws-instance.json)
    aws ec2  attach-network-interface --network-interface-id "$eni" --instance-id $INSTANCEID  --device-index 1
}
