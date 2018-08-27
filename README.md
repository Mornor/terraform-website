## Terraform website, built on top of a custom AMI
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


#### How to
 - `packer build -var-file=variables.json template.json | tee build.log`

#### Testing

### Terraform
- `terraform plan`
- `terraform apply`
