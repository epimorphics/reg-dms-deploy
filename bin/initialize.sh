#!/bin/bash
# Initialize the AWS configuration and the deployment directory

[[ $# = 4 ]] || { echo "Usage: initalize prefix awsaccesskey awssecretkey pemfile" ; exit 1 ; }

PREFIX="$1"
ACCESS_KEY="$2"
SECRET_KEY="$3"
PEM_FILE="$4"

if ! grep -q "$PREFIX" ~/.aws/credentials ; then
    echo "** Add credentials to ~/.aws/credentials"
    mkdir -p ~/.aws
    echo "" >> ~/.aws/credentials
    echo "[$PREFIX]" >> ~/.aws/credentials
    echo "aws_access_key_id=$ACCESS_KEY" >> ~/.aws/credentials
    echo "aws_secret_access_key=$SECRET_KEY" >> ~/.aws/credentials
    echo "" >> ~/.aws/config
    echo "[profile $PREFIX]" >> ~/.aws/config
    echo "region=eu-west-1" >> ~/.aws/config
fi

export AWS_DEFAULT_PROFILE="$PREFIX"

BUCKET="s3://$PREFIX-dms-deploy"
if ! aws s3 ls $BUCKET &> /dev/null ; then
    echo "** Create the S3 bucket for deployments"
    aws s3 mb $BUCKET
fi

echo "** Upload key pair for use in server provisioning and store locally"
cp "$PEM_FILE" ~/.ssh/$PREFIX.pem
chmod 0600 ~/.ssh/$PREFIX.pem
aws s3 cp "$PEM_FILE" "$BUCKET/instance-keys/$PREFIX.pem"

echo "** Configure vacuumetrix access credentials for downloading elb metric data"
mkdir -p tmp
cp templates/vacuumetrix-credential.rb tmp
sed -i tmp/vacuumetrix-credential.rb -e "s|{access_key}|$ACCESS_KEY|"
sed -i tmp/vacuumetrix-credential.rb -e "s|{secret_key}|$SECRET_KEY|"
aws s3 cp tmp/vacuumetrix-credential.rb "$BUCKET/vacuumetrix/vacuumetrix-credential.rb"
rm tmp/vacuumetrix-credential.rb

echo "** Instantiate and copy the AWS configuration into the script areas"
AWS_CONF_FILE=runtime/conf/scripts/config.sh
cp conf/aws-config.sh $AWS_CONF_FILE
sed -i $AWS_CONF_FILE -e "s|{prefix}|$PREFIX|"
cp $AWS_CONF_FILE bin/lib/config.sh

echo "** Customize the chef installation"
CHEF_CONF_FILE=chef/dms_controller/attributes/default.rb
cp templates/chef-config.rb $CHEF_CONF_FILE
sed -i $CHEF_CONF_FILE -e "s|{prefix}|$PREFIX|"
