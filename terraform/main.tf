/*
Terraform template to provision infrastruture for a website/application.
@author Celien Nanson <cesliens@gmail.com>
*/

provider "aws" {
  region                  = "${var.aws_region}"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "private"
}

# Create a VPC with /24, meaning 256 IPs are available
resource "aws_vpc" "website-vpc" {
  cidr_block              = "10.0.0.0/24"
  enable_dns_hostnames    = true
  enable_dns_support      = true
  instance_tenancy        = "default"
}

# Divide this VPC into 2 Subnets with each 127 IPs available
resource "aws_subnet" "website-public-A" {
  vpc_id                  = "${aws_vpc.website-vpc.id}"
  cidr_block              = "10.0.0.0/25"
  availability_zone       = "eu-central-1a"
  #map_public_ip_on_launch = "${var.public_ip_ec2_instance}" # Make IP addresses public
}

resource "aws_subnet" "website-public-B" {
  vpc_id                  = "${aws_vpc.website-vpc.id}"
  cidr_block              = "10.0.0.128/25"
  availability_zone       = "eu-central-1b"
  #map_public_ip_on_launch = "${var.public_ip_ec2_instance}"
}

# Create a public internet gateway
resource "aws_internet_gateway" "public-traffic-ig" {
  vpc_id = "${aws_vpc.website-vpc.id}"
}

# Allow public traffic via route table
resource "aws_route_table" "website-public-rt" {
  vpc_id     = "${aws_vpc.website-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.public-traffic-ig.id}"
  }
}

# Associate the created subnet to the route table
resource "aws_route_table_association" "rt-subnet-website-public-A" {
  subnet_id      = "${aws_subnet.website-public-A.id}"
  route_table_id = "${aws_route_table.website-public-rt.id}"
}

resource "aws_route_table_association" "rt-subnet-website-public-B" {
  subnet_id      = "${aws_subnet.website-public-B.id}"
  route_table_id = "${aws_route_table.website-public-rt.id}"
}


# Create a security group associated to the VPC firstly created
resource "aws_security_group" "website-asg-sg" {
  name        = "website-asg-sg"
  description = "website-asg-sg"
  vpc_id      = "${aws_vpc.website-vpc.id}"

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["${var.public_access_cidr}"] # Replace by an authorized CIDR block
  }

  ingress {
    from_port       = 80 # only allow 80 TCP traffic (so, HTTP)
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["${var.public_access_cidr}"] # Replace by an authorized CIDR block
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

# Create a LB (Load Balancer)
resource "aws_elb" "website-lb" {
  name                        = "website-alb"
  subnets                     = ["${aws_subnet.website-public-A.id}", "${aws_subnet.website-public-B.id}"]
  security_groups             = ["${aws_security_group.website-asg-sg.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 60
  connection_draining         = true # Stops all new data flow to instance but allows existing connections to finish. Smooth transition.
  connection_draining_timeout = 300
  internal                    = "${var.is_elb_internal}"

  listener {
    instance_port      = 80
    instance_protocol  = "http"
    lb_port            = 80
    lb_protocol        = "http"
    ssl_certificate_id = ""
  }

  health_check {
    healthy_threshold   = 10
    unhealthy_threshold = 2
    interval            = 30
    target              = "HTTP:80/"
    timeout             = 5
  }
}

resource "aws_launch_configuration" "website-asg-conf" {
  name                        = "website-asg-conf"
  image_id                    = "${var.ec2-ami}"
  instance_type               = "${var.instance-type}"
  key_name                    = "${var.instance-key}"
  security_groups             = ["${aws_security_group.website-asg-sg.id}"]
  associate_public_ip_address = "${var.public_ip_ec2_instance}"
  enable_monitoring           = false
  ebs_optimized               = false
  user_data                   = "${data.template_file.provision_instance.rendered}"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 8
    delete_on_termination = true
  }
}

# Create an auto-scaling group
resource "aws_autoscaling_group" "website-asg" {
  desired_capacity          = 2
  health_check_grace_period = 300
  health_check_type         = "ELB" # Or EC2
  name                      = "website-asg"
  launch_configuration      = "${aws_launch_configuration.website-asg-conf.id}"
  max_size                  = "${var.ec2_scaling_max_size}"
  min_size                  = "${var.ec2_scaling_min_size}"
  vpc_zone_identifier       = ["${aws_subnet.website-public-A.id}", "${aws_subnet.website-public-B.id}"]
  load_balancers            = ["${aws_elb.website-lb.name}"]

  tag {
    key   = "Name"
    value = "website-asg"
    propagate_at_launch = true
  }
}

# Reference to the cloud_init script
data "template_file" "provision_instance" {
  template = "${file("${path.module}/cloud_init/startup.sh.tpl")}"

  vars {
    docker_container_name = "${var.docker_container_name}"
    docker_container_port = "${var.docker_container_port}"
  }
}
