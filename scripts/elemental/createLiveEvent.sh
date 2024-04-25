#!/bin/bash

# Setup Stream Event Body Variable
streamEventBody="$1"
# Username, user expiration, and user authentication key passed as arguments
username="$2"
userAuthKey="$3"

# Function to calculate the expiration time
calculate_expires() {
    local current_time=$(date -u +%s)  # Get the current time in Unix time in UTC
    local expires=$((current_time + 30))  # Add 30 seconds to the current time
    echo "$expires"
}

# Function to extract the URL path from a URL
extract_url_path() {
    local url="$1"
    local path

    # Remove the protocol and domain part of the URL
    path=$(echo "$url" | sed -E 's/^[^/]*\/\/[^/]*//')

    # Remove any query parameters and fragments from the path
    path=$(echo "$path" | sed 's/\?.*$//' | sed 's/#.*$//')

    # Remove the base URL part
    path=$(echo "$path" | sed "s|^${base_url}||")

    echo "$path"
}

# Function to calculate the hashed key
calculate_hashed_key() {
    local url="$1"
    local expires="$2"  # Expiration time passed as argument
    local urlPath=$(extract_url_path "$url")
    local hashed_key=$(echo -n "${userAuthKey}$(echo -n "${urlPath}${username}${userAuthKey}${expires}" | md5sum | cut -d ' ' -f 1)" | md5sum | cut -d ' ' -f 1)
    echo "$hashed_key"
}

# Function to construct the CURL command with headers
construct_curl_command() {
    local headers="-H 'Content-Type: application/xml' -H 'Accept: application/xml'"
    if [[ -n "$username" && -n "$userAuthKey" ]]; then
        local base_url="http://localhost"  # Base URL for extraction
        local url="${base_url}/api/live_events"  # URL for the request
        # If username and userAuthKey are provided, set headers and use HTTPS
        url="https://${url#http://}"
        local expires=$(calculate_expires)  # Calculate the expiration time only once
        local hashed_key=$(calculate_hashed_key "$url" "$expires")  # Pass expiration time as argument
        headers="-H 'Content-Type: application/xml' -H 'Accept: application/xml' -H 'X-Auth-User: $username' -H 'X-Auth-Expires: $expires' -H 'X-Auth-Key: $hashed_key'"
    fi
    echo "curl -k -s -X POST $headers \"$url\" -d '${streamEventBody}'"
}

# Construct the CURL command
curl_command=$(construct_curl_command)

# Execute the final command
eval "$curl_command"
