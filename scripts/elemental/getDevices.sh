#!/bin/bash
username="$1"
userExpire="$2"
userAuthKey="$3"

# Function to construct the CURL command with headers
construct_curl_command() {
    local url="http://localhost/api/devices.json"
    local headers=""
    if [[ -n "$username" && -n "$userExpire" && -n "$userAuthKey" ]]; then
        # If username, userExpire, and userAuthKey are provided, set headers and use HTTPS
        url="https://${url#http://}"
        headers="-H 'X-Auth-User: $username' -H 'X-Auth-Expires: $userExpire' -H 'X-Auth-Key: $userAuthKey'"
    fi
    echo "curl -k -X GET $headers \"$url\""
}

# Construct the CURL command
curl_command=$(construct_curl_command)

# Execute the final command
eval "$curl_command"
