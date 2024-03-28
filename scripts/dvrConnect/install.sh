#!/bin/bash

# Download the files
sudo curl -o /home/hvroot/hai-cdvr-4.8.0-42.x86_64.rpm https://raw.githubusercontent.com/SardiusMedia/device-manager-scripts/main/scripts/dvrConnect/hai-cdvr-4.8.0-42.x86_64.rpm
sudo curl -o /home/hvroot/hai-madra-2.0.8-40.x86_64.rpm https://raw.githubusercontent.com/SardiusMedia/device-manager-scripts/main/scripts/dvrConnect/hai-madra-2.0.8-40.x86_64.rpm

sudo yum install hai-cdvr-4.8.0-42.x86_64.rpm hai-madra-2.0.8-40.x86_64.rpm --nogpgcheck

