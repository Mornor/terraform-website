## Terraform website/application, built on top of a custom AMI
This repository can be used to
  1. Build the following AWS infrastructure with Terraform
    - 1 VPC (`10.0.0.0/24`)
    - 2 Subnets within this VPC (`10.0.0.0/25` and `10.0.0.128/25`)
    - 1 Internet Gateway for the VPC
    - 2 Route Tables for the 2 Subnets associated to the Internet Gateway
    - 1 Security Group applied to the VPC
    - 1 Auto Scaling Group (2 instances in 2 AZs)
    - 1 Elastic Load Balancer
  2. Build a custom AMI containing a Docker container with Packer, provisioned by Ansible and tested with Serverspec.

### Packer
Packer is used to build a custom AMI, test it with Serverspec, and upload it to AWS (S3) if the tests are successful.

#### What is being built
A custom Docker image is being built by the Packer script, on top of a CentOS image. It only consists of a [index.html](https://github.com/Mornor/terraform-website/blob/master/packer/ansible_roles/roles/website/files/public/index.html) which is exposed through port [`8080`](https://github.com/Mornor/terraform-website/blob/master/packer/ansible_roles/roles/website/files/Dockerfile) using a [Node.js](https://github.com/Mornor/terraform-website/blob/master/packer/ansible_roles/roles/website/files/server.js) server. <br/> Feel  free to adapt it at your own convenience.


#### How to
  - Complete the file `packer/variables.json`
  - `packer build -var-file=variables.json template.json | tee build.log`

#### Testing
  - [Serverspec](https://serverspec.org/) is used to test the AMI before pushing it to AWS. The tests are defined in the `serverspec.sh` [script](https://github.com/Mornor/terraform-website/blob/master/packer/scripts/serverspec.sh). During the build of the AMI, the logs are ouptuted in a `build.log` file. This file is used to grep the IP of the AMI being build and execute tests against it. Once the tests are done, I grepped for the results and check if no errors have been detected (`egrep ' [^1-9] failures' build.log`). If that is the case, the command will exit with `-1`, making the script fails, hence not pushing the AMI to S3. <br/>

### Terraform
- `terraform plan`
- `terraform apply`


### Requirements
- AWS account
-

### Acknowledgements
  - Anna Kennedy for her great [article](http://annaken.github.io/testing-packer-builds-with-serverspec) on testing an AMI with Packer.
