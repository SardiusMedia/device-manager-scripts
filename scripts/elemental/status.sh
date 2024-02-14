#!/bin/bash

# Run status on Elemental REST API
curl_command="curl -X GET http://localhost/system_status.json"

# Execute the final command
eval "$curl_command"
