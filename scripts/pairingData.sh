#!/bin/bash

# Run status.sh script and capture its output
status_output=$(/home/elemental/sardius/elScripts/status.sh)

# Run systemInfo.sh script and capture its output
system_info_output=$(/home/elemental/sardius/elScripts/systemInfo.sh)

# Run devices.sh script and capture its output
devices_output=$(/home/elemental/sardius/elScripts/devices.sh)

# Print the concatenated JSON string
echo "{"
echo "\"Status Output\": $status_output,"
echo "\"System Info Output\": $system_info_output,"
echo "\"Devices Output\": $devices_output"
echo "}"