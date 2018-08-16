#!/bin/bash

# This script is locally executed, but targets the AMI created by Packer

# Requirement: we need to be in the rake directory to execute it
cp -r serverspec/spec-tests/* .
cp -r data/* .

# Get the IP of the AMI built by Packer by greping the log
#PUBLIC_DNS=`grep "PUBLIC_DNS" build.log | cut -d'=' -f2`
TARGET_IP=`grep "TARGET_IP" build.log | cut -d'=' -f2 | egrep -m1 -o '[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}'`

# Define the Target host on which the rake tests will be run against
mkdir spec/$TARGET_IP
mv spec/sample_*.rb spec/$TARGET_IP/

# Pull the Dockerized Serverspec image
docker pull ruby:2.5-rc

# Run tests against the AMI
docker run --rm -v $PWD:/usr/src/app -w /usr/src/app ruby:2.5-rc bash -c "bundle install && gem install serverspec && rake spec SSH_USER=centos"

# Cleanup current directory
rm -rf spec/ website.pem Gemfile Gemfile.lock Rakefile
