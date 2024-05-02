#!/bin/bash

# Presigned URL provided as the first command-line argument
presigned_url="$1"
# Username, user expiration, and user authentication key passed as arguments
username="$2"
userAuthKey="$3"

url="http://localhost/api/live_events.xml"

# Function to calculate the expiration time
calculate_expires() {
    local current_time=$(date -u +%s)  # Get the current time in Unix time in UTC
    local expires=$((current_time + 30))  # Add 30 seconds to the current time
    echo "$expires"
}

# Function to extract the path from a URL
extract_path() {
    local url="$1"
    local path

    # Remove the protocol and domain part of the URL
    path=$(echo "$url" | sed -E 's/^[^/]*\/\/[^/]*//')

    # Remove any query parameters and fragments from the path
    path=$(echo "$path" | sed 's/\?.*$//' | sed 's/#.*$//')

    # Remove the "/api" prefix from the path, if present
    path=$(echo "$path" | sed 's|^/api||')

    echo "$path"
}

# Function to calculate the hashed key
calculate_hashed_key() {
    local url="$1"
    local expires="$2"
    local urlPath=$(extract_path "$url")
    local hashed_key=$(echo -n "${userAuthKey}$(echo -n "${urlPath}${username}${userAuthKey}${expires}" | md5sum | cut -d ' ' -f 1)" | md5sum | cut -d ' ' -f 1)
    echo "$hashed_key"
}

# Function to construct the CURL command with headers
construct_curl_command() {
    local headers=""
    local url_copy="$url"
    if [[ -n "$username" && -n "$userAuthKey" ]]; then
        # If username and userAuthKey are provided, modify URL to use HTTPS
        url_copy="https://${url#http://}"
        local expires=$(calculate_expires)  # Calculate the expiration time only once
        local hashed_key=$(calculate_hashed_key "$url" "$expires")  # Pass expiration time as argument
        headers="-H 'X-Auth-User: $username' -H 'X-Auth-Expires: $expires' -H 'X-Auth-Key: $hashed_key'"
    fi
    echo "curl -k -s -X GET $headers \"$url_copy\""
}

# Build curl command
curl_command=$(construct_curl_command)

# Execute the CURL command to get the actual output
output=$(eval "$curl_command")

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
