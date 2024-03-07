#!/bin/bash

# Presigned URL provided as the first command-line argument
presigned_url="$1"

# Function to extract event IDs from XML
extract_event_ids() {
    local xml="$1"
    local ids=$(echo "$xml" | grep -oP '(?<=href="/live_events/)[0-9]+')
    echo "$ids"
}

# Function to fetch event status for given event ID
fetch_event_status() {
    local event_id="$1"
    local status=$(curl -sX GET "http://localhost/api/live_events/${event_id}/status.json")
    echo "$status"
}

# Run systemInfo.sh script and capture its output
echo "Fetching system status..."
system_status_output=$(curl -sX GET http://localhost/system_status.json)

# Run devices.sh script and capture its output
echo "Fetching devices..."
devices_output=$(curl -sX GET http://localhost/api/devices.json)

# Run get input devices on Elemental REST API and capture the output
echo "Fetching all events XML..."
all_events_xml=$(curl -sX GET http://localhost/api/live_events.xml)

# Extract event IDs from XML
echo "Extracting event IDs..."
event_ids=$(extract_event_ids "$all_events_xml")

# Initialize an empty array to store event statuses
event_statuses=()

# Loop through each event ID and fetch its status
echo "Fetching event statuses..."
for event_id in $event_ids; do
    echo "Fetching status for event ID: $event_id"
    event_status=$(fetch_event_status "$event_id")
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

# Merge JSON responses into one object
merged_json="{\"system_status\":$system_status_output, \"devices\":$devices_output, \"event_statuses\":[$event_statuses_json], \"all_events_xml\":\"$all_events_xml\" }"

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
