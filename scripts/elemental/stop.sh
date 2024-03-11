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
else
    echo "Stop was unsuccessful"
fi
