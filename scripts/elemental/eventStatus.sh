#!/bin/bash

# Setup Stream Event Id Variable
streamEventId="$1"
# file extension determines status endpoint type
extension="$2"
# Username, user expiration, and user authentication key passed as arguments
username="$3"
userExpire="$4"
userAuthKey="$5"

# Function to construct the CURL command with headers
construct_curl_command() {
    local url="http://localhost/api/live_events/${streamEventId}/status.${extension}"
    local headers=""
    if [[ -n "$username" && -n "$userExpire" && -n "$userAuthKey" ]]; then
        # If username, userExpire, and userAuthKey are provided, add headers and use HTTPS
        url="https://localhost/api/live_events/${streamEventId}/status.${extension}"
        headers="-H 'X-Auth-User: $username' -H 'X-Auth-Expires: $userExpire' -H 'X-Auth-Key: $userAuthKey'"
    fi
    echo "curl -X GET $headers \"$url\""
}

# Construct the CURL command
curl_command=$(construct_curl_command)

# Execute the final command
eval "$curl_command"
