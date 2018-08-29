## Terraform website/application, built on top of a custom AMI
This repository can be used to
  1. Build the AWS infrastructure with Terraform (see Terraform section)
  2. Build a custom AMI containing a Docker container with Packer, provisioned by Ansible and tested with Serverspec.

If you'd like to trigger both the creation of the AMI with Packer, use the AMI created and trigger the Terraform template, you can use the - [`execute.sh`](https://github.com/Mornor/terraform-website/blob/master/execute.sh) script.

## Packer
Packer is used to build a custom AMI, test it with Serverspec, and upload it to AWS (S3) if the tests are successful.

#### What is built
A custom Docker image is being built by the Packer script, on top of a CentOS image. It only consists of a [index.html](https://github.com/Mornor/terraform-website/blob/master/packer/ansible_roles/roles/website/files/public/index.html) which is exposed through port [`8080`](https://github.com/Mornor/terraform-website/blob/master/packer/ansible_roles/roles/website/files/Dockerfile) using a [Node.js](https://github.com/Mornor/terraform-website/blob/master/packer/ansible_roles/roles/website/files/server.js) server.

#### How to
  - cd into the packer directory
  - `mkdir keys`
  - Download the Instance Key pair from your AWS account, name it `website.pem`, set the correct rights (`chmod 400 website.pem`) and move it into `packer/keys`
  - Complete the file `packer/variables.json`
  - Reference your AWS profile in the Packer [`template.json`](https://github.com/Mornor/terraform-website/blob/master/packer/template.json#L16)
  - `packer build -var-file=variables.json template.json | tee build.log`

#### Testing
  - [Serverspec](https://serverspec.org/) is used to test the AMI before pushing it to AWS. The tests are defined in the `serverspec.sh` [script](https://github.com/Mornor/terraform-website/blob/master/packer/scripts/serverspec.sh). During the build of the AMI, the logs are ouptuted in a `build.log` file. This file is used to grep the IP of the AMI being build and execute tests against it. Once the tests are done, I grepped for the results and check if no errors have been detected (`egrep ' [^1-9] failures' build.log`). If that is the case, the command will exit with `1`, making the script fails, hence not pushing the AMI to S3. <br/>
  - A [`Vagrantfile`](https://github.com/Mornor/terraform-website/blob/master/packer/ansible_roles/Vagrantfile) is provided and can be used to locally test the Ansible playbook. To test it, just issue `vagrant up --provision`.

## Terraform
#### Architecture
  - 1 VPC (`10.0.0.0/24`)
  - 2 Subnets within this VPC (`10.0.0.0/25` and `10.0.0.128/25`)
  - 1 Internet Gateway for the VPC
  - 2 Route Tables for the 2 Subnets associated to the Internet Gateway
  - 1 Security Group applied to the VPC
  - 1 Auto Scaling Group (2 instances in 2 AZs)
  - 1 Elastic Load Balancer

#### How to
- Build the new AMI with Packer (see Packer section) and copy/paste the AMI id into the `variables.tf` [file](https://github.com/Mornor/terraform-website/blob/master/terraform/variables.tf).
- Change/adapt the `variables.tf` [file](https://github.com/Mornor/terraform-website/blob/master/terraform/variables.tf).
- Check the plan: `terraform plan`
- Apply it: `terraform apply`
- Destroy the infrastructure: `terraform destroy`

### Notes and further enhancements
  - The Ansible playbook should be completely separated from the Packer script, as these two should not be correlated. A good solution would be to upload the playbook to S3, and then download it with Packer.
  - When playing around, make sure you destroyed the snapshots linked to the AMI, as well as the EBS volumes built with Packer.
  - When executing `execute.sh`, would be nice to make sure the script early-exit in case of failures.

### Requirements
  - AWS account
  - packer >= 1.2.1
  - vagrant >= 2.0.3
  - docker >= 18.06.0-ce
  - terraform >= 0.11.7
  - gem >= 2.5.2.3

### Acknowledgements
  - Anna Kennedy for her great [article](http://annaken.github.io/testing-packer-builds-with-serverspec) on testing an AMI with Packer.
