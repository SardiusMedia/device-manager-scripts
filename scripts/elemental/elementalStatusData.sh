#!/bin/bash

# Presigned URL provided as the first command-line argument
presigned_url="$1"
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

    # Remove the "/api" prefix from the path, if present
    path=$(echo "$path" | sed 's|^/api||')

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
    local headers="-H 'Accept: application/xml'"
    if [[ -n "$username" && -n "$userAuthKey" ]]; then
        # If username and userAuthKey are provided, set headers and use HTTPS
        url="https://${url#http://}"
        local expires=$(calculate_expires)  # Calculate the expiration time only once
        local hashed_key=$(calculate_hashed_key "$url" "$expires")  # Pass expiration time as argument
        headers="$headers -H 'X-Auth-User: $username' -H 'X-Auth-Expires: $expires' -H 'X-Auth-Key: $hashed_key'"
    fi
    echo "curl -k -s -X GET $headers \"$url\""
}

# Function to extract event IDs from XML
extract_event_ids() {
    local xml="$1"
    local ids=$(echo "$xml" | grep -oP '(?<=href="/live_events/)[0-9]+')
    echo "$ids"
}

# Create system status command
echo "Fetching system status..."
system_status_command=$(construct_curl_command "http://localhost/api/system_status.json")

# Execute system status curl command
system_status_output=$(eval "$system_status_command")

# Create get devices command
echo "Fetching devices..."
devices_command=$(construct_curl_command "http://localhost/api/devices.json")

# Execute devices curl command
devices_output=$(eval "$devices_command")

# Create get all live events command
echo "Fetching all events XML..."
all_events_xml_command=$(construct_curl_command "http://localhost/api/live_events.xml")

# Execute all live events curl command
all_events_xml_output=$(eval "$all_events_xml_command")

# Extract event IDs from XML
echo "Extracting event IDs..."
event_ids=$(extract_event_ids "$all_events_xml_output")

# Initialize an empty array to store event statuses
event_statuses=()

# Loop through each event ID and fetch its status
echo "Fetching event statuses..."
for event_id in $event_ids; do
    echo "Fetching status for event ID: $event_id"
    event_status_command=$(construct_curl_command "http://localhost/api/live_events/${event_id}/status.json")
    event_status=$(eval "$event_status_command")
    # Append the fetched status as a JSON object to the event_statuses array
    event_statuses+=("$event_status")
done

# Construct the event_statuses array with proper commas
event_statuses_json=""
for ((i=0; i<${#event_statuses[@]}; i++)); do
    if [ $i -eq $((${#event_statuses[@]}-1)) ]; then
        # For the last element, don't add a comma
        event_statuses_json+="$(echo "${event_statuses[i]}")"
    else
        # For other elements, add a comma
        event_statuses_json+="$(echo "${event_statuses[i]}"),"
    fi
done

# Escape double quotes, backslashes, and newline characters in the XML content
escaped_all_events_xml="${all_events_xml_output//\\/\\\\}"
escaped_all_events_xml="${escaped_all_events_xml//\"/\\\"}"
escaped_all_events_xml="${escaped_all_events_xml//$'\n'/\\n}"

# Merge JSON responses into one object
merged_json="{\"system_status\":$system_status_output, \"devices\":$devices_output, \"event_statuses\":[$event_statuses_json], \"all_events_xml\":\"$escaped_all_events_xml\" }"

# Calculate the length of the merged_json data
content_length="${#merged_json}"

# Upload the merged_json to S3 using the presigned URL
echo "Uploading merged JSON to S3..."
curl -X PUT -T <(echo "$merged_json") -H "Content-Length: $content_length" -H "Transfer-Encoding:" "$presigned_url"

# Extract the object key from the presigned URL
object_key=$(echo "$presigned_url" | awk -F "/" '{print $(NF-1)}')

# Return the object key through SSM
echo "Setting object key: $object_key in SSM..."
aws ssm put-parameter --name "ObjectKey" --value "$object_key" --type "String" --overwrite

# Optionally, you may want to print the object key for debugging purposes
echo "Object key: $object_key"
