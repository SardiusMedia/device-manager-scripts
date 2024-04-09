#!/bin/bash

# Setup Stream Channel Variable
streamChannelId="$1"

# Perform variable substitution
# Replace placeholders with the actual values
curl_command="curl -X GET http://localhost:8088/talon/vcu/${streamChannelId}/start"

# Execute the final command
eval "$curl_command"
