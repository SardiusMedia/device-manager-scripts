#!/bin/bash

# Setup Stream Event Body Variable
streamEventBody="$1"

# Perform variable substitution
# Replace placeholders with the actual values
curl_command="curl -X POST http://localhost/api/live_events -H 'Content-Type: application/xml' -H 'Accept: application/xml' -d '${streamEventBody}'
"

# Execute the final command
eval "$curl_command"
