#!/bin/bash

# Function to convert XML to JSON using xml2json tool
xml_to_json() {
    # Assuming xml2json tool is available
    xml2json < "$1"
}

# Function to extract event IDs from XML
extract_event_ids() {
    # Extract event IDs from XML using grep
    grep -oE 'live_events/[0-9]+' <<< "$1" | cut -d'/' -f2
}

# Presigned URL provided as the first command-line argument
presigned_url="$1"

# Run systemInfo.sh script and capture its output
system_status_output=$(curl -sX GET http://localhost/system_status.json)

# Run devices.sh script and capture its output
devices_output=$(curl -sX GET http://localhost/api/devices.json)

# Run get input devices on Elemental REST API and capture the output
all_events_xml=$(curl -sX GET http://localhost/api/live_events.xml)

# Convert XML to JSON
all_events_json=$(xml_to_json <(echo "$all_events_xml"))

# Extract event IDs from JSON
event_ids=$(extract_event_ids "$all_events_xml")

# Array to store event statuses
event_statuses=()

# Loop through each event ID
for eventId in $event_ids; do
    # Call endpoint for event status
    event_status=$(curl -sX GET "http://localhost/api/live_events/${eventId}/status.json")
    event_statuses+=("$event_status")
done

# Merge JSON responses into one object
merged_json="{\"system_status\":$system_status_output, \"devices\":$devices_output, \"all_events\":$all_events_json, \"event_statuses\":${event_statuses[*]}}"

# Calculate the length of the output data
content_length=$(echo -n "$merged_json" | wc -c)

# Upload the output to S3 using the presigned URL
curl -sX PUT -T <(echo "$merged_json") -H "Content-Type: application/json" -H "Content-Length: $content_length" -H "Transfer-Encoding:" "$presigned_url" || { echo "Upload to S3 failed"; exit 1; }

# Extract the object key from the presigned URL
object_key=$(basename "$presigned_url")

# Return the object key through SSM
aws ssm put-parameter --name "ObjectKey" --value "$object_key" --type "String" --overwrite || { echo "Failed to put parameter"; exit 1; }

# Optionally, you may want to print the object key for debugging purposes
echo "Object key: $object_key"
