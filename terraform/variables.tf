variable "aws_region" {
  default = "eu-central-1"
}

variable "aws_region_a" {
  default = "eu-central-1a"
}

variable "aws_region_b" {
  default = "eu-central-1b"
}

variable "public_access_cidr" {
  default = "0.0.0.0/0"
}

variable "public_ip_ec2_instance" {
  default = "true"
}

variable "is_elb_internal" {
  default = "false"
}

# CentOS Linux 7 on eu-central-1
variable "ec2-ami" {
  #default = "ami-337be65c"
  default = "ami-05953085225af2d6a"
}

variable "instance-type" {
  default = "t2.micro"
}

variable "instance-key" {
  default = "website"
}

variable "ec2_scaling_max_size" {
  default = 2
}

variable "ec2_scaling_min_size" {
  default = 2
}

variable "docker_container_name" {
  default = "website"
}

variable "docker_container_port" {
  default = 8080
}
