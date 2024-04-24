#!/bin/bash

# Setup Stream Event Id Variable
streamEventId="$1"
# Username, user expiration, and user authentication key passed as arguments
username="$2"
userExpire="$3"
userAuthKey="$4"

# Function to construct the CURL command with headers
construct_curl_command() {
    local url="http://localhost/api/live_events/${streamEventId}/stop"
    local headers="-H 'Content-Type: application/xml' -H 'Accept: application/xml'"
    if [[ -n "$username" && -n "$userExpire" && -n "$userAuthKey" ]]; then
        # If username, userExpire, and userAuthKey are provided, set headers and use HTTPS
        url="https://${url#http://}"
        headers="$headers -H 'X-Auth-User: $username' -H 'X-Auth-Expires: $userExpire' -H 'X-Auth-Key: $userAuthKey'"
    fi
    echo "curl -X POST $headers -d '<stop></stop>' \"$url\""
}

# Construct the CURL command
curl_command=$(construct_curl_command)

# Execute the final command
eval "$curl_command"
