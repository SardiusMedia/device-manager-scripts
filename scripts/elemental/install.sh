#!/bin/bash

# Hardcoded parameters
sourceUrl='https://raw.githubusercontent.com/SardiusMedia/device-manager-scripts/main/scripts/elemental'
destinationFolder='/home/elemental/sardius/elScripts'
scriptNames='systemInfo.sh network.sh firmware.sh getDevices.sh elementalStatusData.sh getAllEvents.sh pairingData.sh status.sh liveEvent.sh eventStatus.sh createLiveEvent.sh getLiveEvent.sh start.sh stop.sh'

# Create directory structure
sudo mkdir -p /home/elemental/sardius/ssm
sudo mkdir -p "$destinationFolder"

# Download the files
sudo curl -o /home/elemental/sardius/ssm/amazon-ssm-agent.rpm https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo curl -o "$destinationFolder/updateScripts.sh" "$sourceUrl/updateScripts.sh"

# Make the script executable
sudo chmod +x "$destinationFolder/updateScripts.sh"

# Run the updateScripts.sh script
"$destinationFolder/updateScripts.sh" "$sourceUrl" "$destinationFolder" "$scriptNames"

# Install the package
sudo yum install -y /home/elemental/sardius/ssm/amazon-ssm-agent.rpm

# Stop the service
sudo systemctl stop amazon-ssm-agent