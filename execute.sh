#!/bin/bash

PACKER_CONFIG_FILE="variables.json"

# Execute the Packer script
echo "Building the AMI with Packer..."
cd packer
packer build -var-file=${PACKER_CONFIG_FILE} template.json | tee build.log
cd ..
echo "AMI succcessfully built!"

# Fecth the AMI from the Packer build.log, and set it as a the AMI use by terraform
AMI_ID="$(tail -2 packer/build.log | awk 'match($0, /ami-.*/) { print substr($0, RSTART, RLENGTH) }')"
sed -i "" -E s/ami-.*/${AMI_ID}\"/g terraform/variables.tf

# Run the Terraform script
echo "Applying Terraform template..."
cd terraform
terraform apply
echo "Terraforming done!"
