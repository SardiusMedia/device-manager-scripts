#!/bin/bash

# Presigned URL provided as the first command-line argument
presigned_url="$1"

# Run get input devices on Elemental REST API and capture the output
output=$(curl -X GET http://localhost/api/live_events.json)

# Upload the output to S3 using the presigned URL
curl -X PUT -T <(echo "$output") "$presigned_url"

# Extract the object key from the presigned URL
object_key=$(echo "$presigned_url" | awk -F "/" '{print $(NF-1)}')

# Return the object key through SSM
aws ssm put-parameter --name "ObjectKey" --value "$object_key" --type "String" --overwrite

# Optionally, you may want to print the object key for debugging purposes
echo "Object key: $object_key"