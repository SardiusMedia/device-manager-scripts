#!/bin/bash

# Function to fetch data with or without headers based on arguments
fetch_with_headers() {
    local url="$1"
    local headers=""
    if [[ -n "$username" && -n "$userExpire" && -n "$userAuthKey" ]]; then
        # If username, userExpire, and userAuthKey are provided, set headers and use HTTPS
        url="https://${url#http://}"
        headers="-H 'X-Auth-User: $username' -H 'X-Auth-Expires: $userExpire' -H 'X-Auth-Key: $userAuthKey'"
    fi
    curl -sX GET $headers "$url"
}

# Presigned URL provided as the first command-line argument
presigned_url="$1"
username="$2"
userExpire="$3"
userAuthKey="$4"

# Run get input devices on Elemental REST API and capture the output
output=$(fetch_with_headers "http://localhost/api/live_events.xml")

# Calculate the length of the output data
content_length=$(echo -n "$output" | wc -c)

# Upload the output to S3 using the presigned URL
curl -X PUT -T <(echo "$output") -H "Content-Length: $content_length" -H "Transfer-Encoding:" "$presigned_url"

# Extract the object key from the presigned URL
object_key=$(echo "$presigned_url" | awk -F "/" '{print $(NF-1)}')

# Return the object key through SSM
aws ssm put-parameter --name "ObjectKey" --value "$object_key" --type "String" --overwrite

# Optionally, you may want to print the object key for debugging purposes
echo "Object key: $object_key"
