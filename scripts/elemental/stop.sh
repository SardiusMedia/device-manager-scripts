#!/bin/bash

# Setup Stream Event Id Variable
streamEventId="$1"
# Username, user expiration, and user authentication key passed as arguments
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
    local url="$1"
    local headers="$2"
    local method="$3"
    local data="$4"
    if [[ -n "$username" && -n "$userAuthKey" ]]; then
        # If username and userAuthKey are provided, use HTTPS, calculate expires, and include headers
        url="https://${url#http://}"
        local expires=$(calculate_expires)
        local hashed_key=$(calculate_hashed_key "$url" "$expires")
        headers="$headers -H 'X-Auth-User: $username' -H 'X-Auth-Expires: $expires' -H 'X-Auth-Key: $hashed_key'"
    fi
    echo "curl -k -s -X $method \"$url\" $headers $data"
}

# Function to check if the event is no longer running
check_event_status() {
    # Define the URL for status check
    status_command=$(construct_curl_command "http://localhost/api/live_events/${streamEventId}/status.json" "" "GET" )

    # Execute stop curl command
    status_output=$(eval "$status_command")
    if [ $? -ne 0 ]; then
        echo "Error occurred during status command execution: $status_output" >&2
        exit 1
    fi

    event_status=$(echo $status_output | grep -o '"status": *"[^"]*"' | cut -d '"' -f 4)
    
    if [ "$event_status" != "running" ]; then
        return 0
    else
        return 1
    fi
}

delete_event() {
    # Generate delete curl command
    delete_command=$(construct_curl_command "http://localhost/api/live_events/${streamEventId}.json" "" "DELETE")

    # Execute stop curl command
    delete_output=$(eval "$delete_command")
    if [ $? -ne 0 ]; then
        echo "Error occurred during delete command execution: $delete_output" >&2
        exit 1
    fi
    
    # Check if the delete was successful
    if [[ $delete_output != *"Invalid command"* ]]; then
        echo "Stop and Delete Executed" >&2
    else
        echo "$delete_output" >&2
    fi
}

if check_event_status; then
    delete_event
else 
    # Generate stop curl command
    stop_command=$(construct_curl_command "http://localhost/api/live_events/${streamEventId}/stop.json" "-H 'Content-Type: application/xml' -H 'Accept: application/xml'" "POST" "-d '<stop></stop>'")

    # Execute stop curl command
    stop_output=$(eval "$stop_command")
    if [ $? -ne 0 ]; then
        echo "Error occurred during stop command execution: $stop_output" >&2
        exit 1
    fi

    # Check if the stop was successful
    if [[ $stop_output == *"Event successfully stopped"* ]]; then
        
        # Loop to check the event status until it's no longer running or max attempts reached
        attempts=0
        max_attempts=20
        while [ $attempts -lt $max_attempts ]; do
            if check_event_status; then
                break
            else
                sleep .5  # Sleep for half a second
                ((attempts++))
            fi
        done
        
        delete_event
    fi
fi