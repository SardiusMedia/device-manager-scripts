#!/bin/bash

# Function to construct the CURL command with headers
construct_curl_command() {
    local url="http://localhost/api/live_events/${streamEventId}.json"
    if [[ -n "$username" && -n "$userExpire" && -n "$userAuthKey" ]]; then
        # If username, userExpire, and userAuthKey are provided, use HTTPS and include headers
        url="https://${url#http://}"
        headers="-H 'X-Auth-User: $username' -H 'X-Auth-Expires: $userExpire' -H 'X-Auth-Key: $userAuthKey'"
    fi
    echo "curl -X POST $headers \"$url\""
}

# Setup Stream Event Id Variable
streamEventId="$1"

# Construct the CURL command
curl_command=$(construct_curl_command)

# Execute the final command
eval "$curl_command"
