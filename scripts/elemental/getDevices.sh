#!/bin/bash

# Username, user expiration, and user authentication key passed as arguments
username="$1"
userExpire="$2"
userAuthKey="$3"

# Function to calculate the hashed key
calculate_hashed_key() {
    local url="http://localhost/api/devices.json"
    local path_without_api_version=$(echo "$url" | sed -E 's/\/api(?:\/[^\/]*[0-9]+(?:\.[0-9]+)*[^\/]*)?//i')
    local expires=$(( $(date -u +%s) + 30 ))
    local hashed_key=$(echo -n "${userAuthKey}$(echo -n "${userAuthKey}${path_without_api_version}${username}${userAuthKey}${expires}" | md5sum | cut -d ' ' -f 1)" | md5sum | cut -d ' ' -f 1)
    echo "$hashed_key"
}

# Function to construct the CURL command with headers
construct_curl_command() {
    local url="http://localhost/api/devices.json"
    local headers=""
    if [[ -n "$username" && -n "$userExpire" && -n "$userAuthKey" ]]; then
        # If username, userExpire, and userAuthKey are provided, set headers and use HTTPS
        url="https://${url#http://}"
        local hashed_key=$(calculate_hashed_key)
        headers="-H 'X-Auth-User: $username' -H 'X-Auth-Expires: $userExpire' -H 'X-Auth-Key: $hashed_key'"
    fi
    echo "curl -k -X GET $headers \"$url\""
}

# Construct the CURL command
curl_command=$(construct_curl_command)

# Execute the final command
eval "$curl_command"
