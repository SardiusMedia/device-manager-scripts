#!/bin/bash

# Setup Stream Event Id Variable
streamEventId="$1"
# Username and user authentication key passed as arguments
username="$2"
userAuthKey="$3"

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

    echo "$path"
}

# Function to calculate the hashed key
calculate_hashed_key() {
    local url="$1"
    local expires="$2"  # Pass expiration time as argument
    local urlPath=$(extract_path "$url")
    local hashed_key=$(echo -n "${userAuthKey}$(echo -n "${urlPath}${username}${userAuthKey}${expires}" | md5sum | cut -d ' ' -f 1)" | md5sum | cut -d ' ' -f 1)
    echo "$hashed_key"
}

# Function to construct the CURL command with headers
construct_curl_command() {
    local url="http://localhost/api/live_events/${streamEventId}/stop"
    local headers="-H 'Content-Type: application/xml' -H 'Accept: application/xml'"
    if [[ -n "$username" && -n "$userAuthKey" ]]; then
        # If username and userAuthKey are provided, use HTTPS, calculate expires, and include headers
        url="https://${url#http://}"
        local expires=$(calculate_expires)
        local hashed_key=$(calculate_hashed_key "$url" "$expires")
        headers="$headers -H 'X-Auth-User: $username' -H 'X-Auth-Expires: $expires' -H 'X-Auth-Key: $hashed_key'"
    fi
    echo "curl -k -s -X POST $headers -d '<stop></stop>' \"$url\""
}

# Construct the CURL command
curl_command=$(construct_curl_command)

# Execute the final command
eval "$curl_command"
