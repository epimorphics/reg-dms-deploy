#!/bin/bash
# Initialize the AWS configuration and the deployment directory

[[ $# = 4 ]] || { echo "Usage: initalize prefix awsaccesskey awssecretkey pemfile" ; exit 1 ; }

PREFIX="$1"
ACCESS_KEY="$2"
SECRET_KEY="$3"
PEM_FILE="$4"

export AWS_DEFAULT_PROFILE="$PREFIX"

echo "** Record configuration name" 
echo "PRREFIX=$PREFIX" > conf/config.sh
echo "AWS_DEFAULT_PROFILE=$PREFIX" >> conf/config.sh

if ! grep -q "$PREFIX" ~/.aws/credentials ; then
    echo "** Add credentials to ~/.aws/credentials"
    echo "" >> ~/.aws/credentials
    echo "[$PREFIX]" >> ~/.aws/credentials
    echo "aws_access_key_id=$ACCESS_KEY" >> ~/.aws/credentials
    echo "aws_secret_access_key=$SECRET_KEY" >> ~/.aws/credentials
    echo "" >> ~/.aws/config
    echo "[profile $PREFIX]" >> ~/.aws/config
    echo "region=eu-west-1" >> ~/.aws/config
fi

echo "** Create the S3 bucket for deployments"
aws s3 mb s3://$PREFIX-dms-deploy

echo "** Upload key pair for use in server provisioning and store locally"
cp "$PEM_FILE" ~/.ssh/$PREFIX.pem
chmod 0600 ~/.ssh/$PREFIX.pem
aws s3 cp "$PEM_FILE" "s3://$PREFIX-dms-deploy/instance-keys/$PREFIX.pem"

echo "** Configure vacuumetrix access credentials for downloading elb metric data"
mkdir -p tmp
cp templates/vacuumetrix-credential.rb tmp
sed -i tmp/vacuumetrix-credential.rb -e "s|{access_key}|$ACCESS_KEY|"
sed -i tmp/vacuumetrix-credential.rb -e "s|{secret_key}|$SECRET_KEY|"
aws s3 cp tmp/vacuumetrix-credential.rb "s3://$PREFIX-dms-deploy/vacuumetrix/vacuumetrix-credential.rb"
rm tmp/vacuumetrix-credential.rb

