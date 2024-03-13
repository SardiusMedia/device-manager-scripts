#!/bin/bash

# Setup Stream Event Id Variable
streamEventId="$1"

# Perform variable substitution for stop command
stop_output=$(curl -X POST http://localhost/api/live_events/${streamEventId}/stop.json -H 'Content-Type: application/xml' -H 'Accept: application/xml' -d '<stop></stop>')

# Check if the stop was successful
if [[ $stop_output == *"Event successfully stopped"* ]]; then
    echo "Stop was successful"
    # Perform variable substitution for delete command
    delete_output=$(curl -X DELETE http://localhost/api/live_events/${streamEventId}.json)
    if [[ $delete_output == *"Invalid command"* ]]; then
        echo "Delete was unsuccessful: $delete_output"
    else
        echo "Delete executed"
    fi
elif [[ $stop_output == *"Invalid command: Live Event "* ]]; then
    echo "Stop was unsuccessful: $stop_output"
    echo "Trying delete command instead"
    # Extracting the Live Event ID from the stop_output
    event_id=$(echo "$stop_output" | grep -oE '[0-9]+')
    # Perform variable substitution for delete command using the extracted event_id
    delete_output=$(curl -X DELETE http://localhost/api/live_events/${event_id}.json)
    if [[ $delete_output == *"Invalid command"* ]]; then
        echo "Delete was unsuccessful: $delete_output"
    else
        echo "Delete executed"
    fi
else
    echo "Stop was unsuccessful"
fi
