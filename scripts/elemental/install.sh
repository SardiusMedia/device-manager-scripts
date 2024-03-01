#!/bin/bash

# Create directory structure
mkdir -p /home/elemental/sardius/ssm

# Download the file
curl -o /home/elemental/sardius/ssm/amazon-ssm-agent.rpm https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

# Install the package
sudo yum install -y /home/elemental/sardius/ssm/amazon-ssm-agent.rpm

# Stop the service
sudo systemctl stop amazon-ssm-agent
