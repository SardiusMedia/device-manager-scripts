http://192.168.11.179/devices.json

#!/bin/bash

# Setup Stream Event Id Variable
streamEventId="$1"

# Perform variable substitution
# Replace placeholders with the actual values
curl_command="curl -X POST http://localhost/api/devices.json"

# Execute the final command
eval "$curl_command"