#!/bin/bash

# Run updateScripts.sh script and capture its output
update_scripts_output=$(/home/elemental/sardius/elScripts/updateScripts.sh)

# Check if updateScripts.sh was successful
if [ $? -ne 0 ]; then
  echo "updateScripts.sh failed. Exiting."
  exit 1
fi

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
