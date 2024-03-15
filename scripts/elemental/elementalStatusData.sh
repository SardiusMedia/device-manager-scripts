#!/bin/bash

# Presigned URL provided as the first command-line argument
presigned_url="$1"

# Function to extract event IDs from XML
extract_event_ids() {
    local xml="$1"
    grep -oP '(?<=href="/live_events/)[0-9]+' <<< "$xml"
}

# Function to fetch event status for given event ID
fetch_event_status() {
    local event_id="$1"
    curl -sX GET "http://localhost/api/live_events/${event_id}/status.json"
}

# Fetch system status in the background
echo "Fetching system status..."
system_status_output=$(curl -sX GET http://localhost/system_status.json &)

# Fetch devices in the background
echo "Fetching devices..."
devices_output=$(curl -sX GET http://localhost/api/devices.json &)

# Fetch all events XML in the background
echo "Fetching all events XML..."
all_events_xml=$(curl -sX GET http://localhost/api/live_events.xml &)

# Wait for all background processes to finish
wait

# Extract event IDs from XML
echo "Extracting event IDs..."
event_ids=$(extract_event_ids "$all_events_xml")

# Fetch event statuses in parallel using GNU Parallel
echo "Fetching event statuses..."
event_statuses=($(parallel -j 10 fetch_event_status ::: $event_ids))

# Construct the event_statuses array with proper commas
event_statuses_json=$(printf '%s\n' "${event_statuses[@]}" | paste -sd ',' -)

# Escape double quotes, backslashes, and newline characters in the XML content
escaped_all_events_xml=$(sed 's/\\/\\\\/g; s/"/\\"/g; s/$/\\n/' <<< "$all_events_xml")

# Merge JSON responses into one object
merged_json="{\"system_status\":$system_status_output, \"devices\":$devices_output, \"event_statuses\":[$event_statuses_json], \"all_events_xml\":\"$escaped_all_events_xml\" }"

# Calculate the length of the merged_json data
content_length="${#merged_json}"

# Upload the merged_json to S3 using the presigned URL
echo "Uploading merged JSON to S3..."
curl -X PUT -T <(echo "$merged_json") -H "Content-Length: $content_length" -H "Transfer-Encoding:" "$presigned_url"

# Extract the object key from the presigned URL
object_key=$(basename "$presigned_url")

# Return the object key through SSM
echo "Setting object key: $object_key in SSM..."
aws ssm put-parameter --name "ObjectKey" --value "$object_key" --type "String" --overwrite

# Optionally, you may want to print the object key for debugging purposes
echo "Object key: $object_key"
