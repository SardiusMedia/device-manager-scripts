#!/bin/bash

# Run status.sh script and capture its output
network_output=$(/home/elemental/sardius/elScripts/networkSettings.sh)

# Run systemInfo.sh script and capture its output
system_info_output=$(/home/elemental/sardius/elScripts/systemInfo.sh)

# Run devices.sh script and capture its output
devices_output=$(/home/elemental/sardius/elScripts/devices.sh)

# Print the concatenated JSON string
echo -n "{"
echo -n  "\"NetworkSettings\": $network_output,"
echo -n  "\"SystemInfo\": $system_info_output,"
echo -n  "\"Devices\": $devices_output"
echo -n  "}"