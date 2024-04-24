#!/bin/bash

# Username and user authentication key passed as arguments
username="$1"
userAuthKey="$2"

# Function to calculate the expiration time
calculate_expires() {
    local current_time=$(date -u +%s)  # Get the current time in Unix time in UTC
    local expires=$((current_time + 30))  # Add 30 seconds to the current time
    echo "$expires"
}

# Function to calculate the hashed key
calculate_hashed_key() {
    local url="http://localhost/api/devices.json"
    local path_without_api_version=$(echo "$url" | sed -E 's/\/api[^\/]+//i')
    local expires="$1"  # Expiration time passed as argument
    local hash1="$(echo -n "${path_without_api_version}${username}${userAuthKey}${expires}" | md5sum | cut -d ' ' -f 1)"
    local hashed_key=$(echo -n "${userAuthKey}${hash1}" | md5sum | cut -d ' ' -f 1)
    echo "$hashed_key"
}

# md5(api_key + md5(url + X-Auth-User + api_key + X-Auth-Expires))

local concat_str1="${path_without_api_version}${username}${userAuthKey}${expires}"
local concat_str1="${path_without_api_version}${username}${userAuthKey}${expires}"



# Function to construct the CURL command with headers
construct_curl_command() {
    local url="http://localhost/api/devices.json"
    local headers=""
    if [[ -n "$username" && -n "$userAuthKey" ]]; then
        # If username and userAuthKey are provided, set headers and use HTTPS
        url="https://${url#http://}"
        local expires=$(calculate_expires)  # Calculate the expiration time only once
        local hashed_key=$(calculate_hashed_key "$expires")  # Pass expiration time as argument
        headers="-H 'X-Auth-User: $username' -H 'X-Auth-Expires: $expires' -H 'X-Auth-Key: $hashed_key'"
    fi
    echo "curl -k -X GET $headers \"$url\""
}

# Construct the CURL command
curl_command=$(construct_curl_command)
echo "CURL command: $curl_command"

# Execute the final command
eval "$curl_command"