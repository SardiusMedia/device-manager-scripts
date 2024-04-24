#!/bin/bash

# Presigned URL provided as the first command-line argument
presigned_url="$1"
# Username, user expiration, and user authentication key passed as arguments
username="$2"
userAuthKey="$3"

# Run systemInfo.sh, getDevices.sh, network.sh, and firmware.sh scripts concurrently
system_info_output=$(/home/elemental/sardius/elScripts/systemInfo.sh "$username" "$userAuthKey" &)
devices_output=$(/home/elemental/sardius/elScripts/getDevices.sh "$username" "$userAuthKey" &)
network_output=$(/home/elemental/sardius/elScripts/network.sh "$username" "$userAuthKey" &)
firmware_output=$(/home/elemental/sardius/elScripts/firmware.sh &)

# Wait for all background jobs to finish
wait

# Concatenate JSON strings
output="{\"SystemInfo\": \"$system_info_output\", \"Devices\": \"$devices_output\", \"NetworkSettings\": \"$network_output\", \"Version\": \"$firmware_output\"}"

# Calculate content length
content_length=${#output}

# Upload the output to S3 using the presigned URL, mask the output
if curl_output=$(curl -s -X PUT -T <(echo "$output") -H "Content-Length: $content_length" -H "Transfer-Encoding:" "$presigned_url"); then
    echo -n "success"
else
    echo -n "failed"
fi
