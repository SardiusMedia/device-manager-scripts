#!/bin/bash

# Create directory structure
sudo mkdir -p /home/elemental/sardius/ssm
sudo mkdir -p /home/elemental/sardius/elScripts

# Download the files
sudo curl -o /home/elemental/sardius/ssm/amazon-ssm-agent.rpm https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo curl -o /home/elemental/sardius/elScripts/updateScripts.sh https://raw.githubusercontent.com/SardiusMedia/device-manager-scripts/main/scripts/elemental/updateScripts.sh

# Make the script executable
sudo chmod +x /home/elemental/sardius/elScripts/updateScripts.sh

echo "Attempting to install Amazon SSM Agent..."

# Install the package, automatically answering yes to prompts
echo "yes" | sudo yum install -y /home/elemental/sardius/ssm/amazon-ssm-agent.rpm | true

# Check if the installation was successful
if [ $? -eq 0 ]; then
    echo "Amazon SSM Agent installed successfully."
else
    echo "Amazon SSM Agent is already installed. Nothing to do."
fi

# Stop the service
sudo systemctl stop amazon-ssm-agent
