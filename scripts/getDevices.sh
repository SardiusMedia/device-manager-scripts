http://192.168.11.179/devices.json

#!/bin/bash

# Gets input devices from Elemental 
curl_command="curl -X POST http://localhost/api/devices.json"

# Execute the final command
eval "$curl_command"