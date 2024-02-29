#!/bin/bash

# Run get input devices on Elemental REST API
curl_command="curl -X GET http://localhost/api/live_events.json"

# Execute the final command
eval "$curl_command"