#!/bin/bash

# This script could fails because of race conditions.

PACKER_CONFIG_FILE="variables.json"

# Execute the Packer script
echo "Building the AMI with Packer..."
cd packer
packer build -var-file=${PACKER_CONFIG_FILE} template.json | tee build.log
cd ..
echo "AMI succcessfully built!"

# Fetch the AMI from the Packer build.log, and set it as a the AMI use by terraform
PACKER_AMI_ID="$(awk 'match($0, /ami-.*/) { x = substr($0, RSTART, RLENGTH) } END { print x }' packer/build.log)"
CENTOS_AMI_ID="$(cat terraform/variables.tf | egrep -m1 -o 'ami-.{8}')"
sed -i "" -E s/ami-.*/${PACKER_AMI_ID}\"/g terraform/variables.tf

# Run the Terraform script
echo "Applying Terraform template..."
cd terraform
terraform apply -auto-approve
cd ..
echo "Terraforming done!"

# Reset CentOS AMI on the terraform/variables.tf file
sed -i "" -E s/ami-.*/${CENTOS_AMI_ID}\"/g terraform/variables.tf
