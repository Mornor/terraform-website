#!/bin/bash
sleep 15

set -xe

# Install all the necessary tools and dependencies
#sudo yum -y update
sudo yum -y install git
sudo yum -y install ansible
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum makecache fast
sudo yum install -y docker-ce
sudo yum --enablerepo=extras install -y epel-release
sudo yum -y install python-pip
sudo pip install --upgrade docker-py
