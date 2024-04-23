#!/bin/bash

# Setup Stream Event Body Variable
streamEventBody="$1"

# Check if username, userExpire, and userAuthKey are defined
if [[ -n "$2" && -n "$3" && -n "$4" ]]; then
    # Construct the curl command with HTTPS URL and additional headers
    curl_command="curl -X POST https://localhost/api/live_events \
        -H 'Content-Type: application/xml' \
        -H 'Accept: application/xml' \
        -H 'X-Auth-User: $2' \
        -H 'X-Auth-Expires: $3' \
        -H 'X-Auth-Key: $4' \
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
