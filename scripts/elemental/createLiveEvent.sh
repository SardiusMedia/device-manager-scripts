#!/bin/bash

# Setup Stream Event Body Variable
streamEventBody="$1"
# Username, user expiration, and user authentication key passed as arguments
username="$2"
userExpire="$3"
userAuthKey="$4"

# Check if username, userExpire, and userAuthKey are defined
if [[ -n "$username" && -n "$userExpire" && -n "$userAuthKey" ]]; then
    # Construct the curl command with HTTPS URL and additional headers
    curl_command="curl -k -X POST https://localhost/api/live_events \
        -H 'Content-Type: application/xml' \
        -H 'Accept: application/xml' \
        -H 'X-Auth-User: $username' \
        -H 'X-Auth-Expires: $userExpire' \
        -H 'X-Auth-Key: $userAuthKey' \
        -d '${streamEventBody}'"
else
    # Construct the curl command with HTTP URL
    curl_command="curl -X POST http://localhost/api/live_events \
        -H 'Content-Type: application/xml' \
        -H 'Accept: application/xml' \
        -d '${streamEventBody}'"
fi

# Execute the final command
eval "$curl_command"
