#!/bin/bash

# Setup Stream Event Id Variable
streamEventId="$1"

# Perform variable substitution
# Replace placeholders with the actual values
curl_command="curl -X POST http://localhost/api/live_events/${streamEventId}/reset -H 'Content-Type: application/xml' -H 'Accept: application/xml' -d '<reset></reset>'"

# Execute the final command
eval "$curl_command"