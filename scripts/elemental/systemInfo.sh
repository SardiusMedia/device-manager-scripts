#!/bin/bash

# Run system info on Elemental REST API
curl_command="curl -X GET http://localhost/system_info.json"

# Execute the final command
eval "$curl_command"
