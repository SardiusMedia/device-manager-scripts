#!/bin/bash

# Run systemInfo.sh, getDevices.sh, network.sh, and firmware.sh scripts concurrently
system_info_output=$(/home/elemental/sardius/elScripts/systemInfo.sh &)
devices_output=$(/home/elemental/sardius/elScripts/getDevices.sh &)
network_output=$(/home/elemental/sardius/elScripts/network.sh &)
firmware_output=$(/home/elemental/sardius/elScripts/firmware.sh &)

# Wait for all background jobs to finish
wait

# Print the concatenated JSON string
echo -n "{"
echo -n  "\"SystemInfo\": $system_info_output,"
echo -n  "\"Devices\": $devices_output,"
echo -n  "\"NetworkSettings\": $network_output,"
echo -n  "\"Version\": \"$firmware_output\""
echo -n  "}"
