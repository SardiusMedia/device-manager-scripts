http://192.168.11.179/devices.json

#!/bin/bash

# Run get input devices on Elemental REST API
curl_command="curl -X GET http://localhost/api/devices.json"

# Execute the final command
eval "$curl_command"