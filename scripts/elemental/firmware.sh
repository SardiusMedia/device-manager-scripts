#!/bin/bash

# Run the command and capture the output
output=$(cat /opt/elemental_se/versions.txt)

# Filter the line containing "Elemental Live (CPU)" and extract the version number
elemental_live_version=$(echo "$output" | grep "Elemental Live (CPU)" | awk '{print $NF}')

# Output the extracted version number
echo "$elemental_live_version"