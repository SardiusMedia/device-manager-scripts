#!/bin/bash

# Create directory structure
mkdir -p /home/elemental/sardius/ssm
mkdir -p /home/elemental/sardius/elScripts

# Download the files
curl -o /home/elemental/sardius/ssm/amazon-ssm-agent.rpm https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
curl -o /home/elemental/sardius/elScripts/updateScripts.sh https://raw.githubusercontent.com/SardiusMedia/elementalScripts/main/scripts/updateScripts.sh

# Make the script executable
chmod +x /home/elemental/sardius/elScripts/updateScripts.sh

# Install the package
sudo yum install -y /home/elemental/sardius/ssm/amazon-ssm-agent.rpm

# Stop the service
sudo systemctl stop amazon-ssm-agent

