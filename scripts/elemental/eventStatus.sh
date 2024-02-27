#!/bin/bash

# Setup Stream Event Id Variable
streamEventId="$1"
# file extension determines status endpoint type
extension="$2"

# Perform variable substitution
# Replace placeholders with the actual values
curl_command="curl -X GET http://localhost/api/live_events/${streamEventId}/status.${extension}"

# Execute the final command
eval "$curl_command"