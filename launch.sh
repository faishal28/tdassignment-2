#!/bin/bash
##### Install Ansible ######
apt-get --assume-yes update
apt-get --assume-yes install git-all
apt-get --assume-yes install python3-pip
pip3 install molecule boto boto3
apt-get --assume-yes install ansible 
##### Clone ansible repository ######
git clone https://github.com/faishal28/tdassignment-2-setup.git
cd tdassignment-2-setup

##### Run your ansible playbook for only autoscaled and not initialised instances ######
ansible-playbook setup.yml