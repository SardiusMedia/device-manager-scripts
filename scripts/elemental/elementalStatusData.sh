#!/bin/bash

# Function to convert XML to JSON using yq
xml_to_json_yq() {
    local xml="$1"
    local json=$(yq e -o=json "$xml")
    echo "$json"
}

# Directory to download yq binary
yq_directory="/home/elemental/sardius/yq"

# Check if yq is available, if not, install it
if ! command -v yq &> /dev/null; then
    echo "yq is not installed. Installing..."

    # Download yq binary to the specified directory
    mkdir -p "$yq_directory"
    curl -sL https://github.com/mikefarah/yq/releases/download/v4.13.2/yq_linux_amd64 -o "$yq_directory/yq"

    # Make yq executable
    chmod +x "$yq_directory/yq"
fi

# Function to convert XML content to JSON
convert_xml_to_json() {
    local xml_content="$1"
    local json_content=$(xml_to_json_yq "$xml_content")
    echo "$json_content"
}

# Function to extract event IDs from JSON
extract_event_ids() {
    local json="$1"
    local ids=$(echo "$json" | yq e '.[].href' - | grep -oE '[0-9]+')
    echo "$ids"
}

# Function to fetch event status for given event ID
fetch_event_status() {
    local event_id="$1"
    local status=$(curl -sX GET "http://localhost/api/live_events/${event_id}/status.json")
    echo "$status"
}

# Run systemInfo.sh script and capture its output
system_status_output=$(curl -sX GET http://localhost/system_status.json)

# Run devices.sh script and capture its output
devices_output=$(curl -sX GET http://localhost/api/devices.json)

# Run get input devices on Elemental REST API and capture the output
all_events_xml=$(curl -sX GET http://localhost/api/live_events.xml)

# Convert XML to JSON
all_events_json=$(convert_xml_to_json "$all_events_xml")

# Extract event IDs from JSON
event_ids=$(extract_event_ids "$all_events_json")

# Array to store event statuses
event_statuses=()

# Loop through each event ID and fetch its status
for event_id in $event_ids; do
    event_status=$(fetch_event_status "$event_id")
    event_statuses+=("$event_status")
done

# Merge JSON responses into one object
merged_json="{\"system_status\":$system_status_output, \"devices\":$devices_output, \"all_events\":$all_events_json, \"event_statuses\":${event_statuses[*]}}"

# Calculate the length of the output data
content_length=$(echo -n "$output" | wc -c)

# Upload the output to S3 using the presigned URL
curl -X PUT -T <(echo "$merged_json") -H "Content-Length: $content_length" -H "Transfer-Encoding:" "$presigned_url"

# Extract the object key from the presigned URL
object_key=$(echo "$presigned_url" | awk -F "/" '{print $(NF-1)}')

# Return the object key through SSM
aws ssm put-parameter --name "ObjectKey" --value "$object_key" --type "String" --overwrite

# Optionally, you may want to print the object key for debugging purposes
echo "Object key: $object_key"
