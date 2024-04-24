#!/bin/bash

# Username and user authentication key passed as arguments
username="$1"
userAuthKey="$2"

# Function to calculate the expiration time
calculate_expires() {
    local current_time=$(date -u +%s)  # Get the current time in Unix time in UTC
    local expires=$((current_time + 30))  # Add 30 seconds to the current time
    echo "Expiration time (UTC): $expires"
    echo "$expires"
}

# Function to calculate the hashed key
calculate_hashed_key() {
    local url="http://localhost/api/devices.json"
    local path_without_api_version=$(echo "$url" | sed -E 's/\/api[^\/]+//i')
    local expires=$(calculate_expires)  # Calculate the expiration time
    local concat_str="${userAuthKey}${path_without_api_version}${username}${userAuthKey}${expires}"
    local md5_result=$(echo -n "$concat_str" | md5sum)
    local hashed_key=$(echo -n "${userAuthKey}${md5_result}" | md5sum)
    echo "MD5 result: $md5_result"
    echo "Hashed key: $hashed_key"
    echo "$hashed_key" | cut -d ' ' -f 1
}

# Function to construct the CURL command with headers
construct_curl_command() {
    local url="http://localhost/api/devices.json"
    local headers=""
    if [[ -n "$username" && -n "$userAuthKey" ]]; then
        # If username and userAuthKey are provided, set headers and use HTTPS
        url="https://${url#http://}"
        local expires=$(calculate_expires)
        local hashed_key=$(calculate_hashed_key)
        headers="-H 'X-Auth-User: $username' -H 'X-Auth-Expires: $expires' -H 'X-Auth-Key: $hashed_key'"
        echo "Headers: $headers"
    fi
    echo "curl -k -X GET $headers \"$url\""
}

# Construct the CURL command
curl_command=$(construct_curl_command)
echo "CURL command: $curl_command"

# Execute the final command
eval "$curl_command"
