#!/bin/bash

# Setup Stream Event Id Variable
streamEventId="$1"

# Perform variable substitution
# Replace placeholders with the actual values
curl_command="curl -X GET http://localhost/api/live_events/${streamEventId}/status.xml"

# Execute the final command
eval "$curl_command"