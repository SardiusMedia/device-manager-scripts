#!/bin/bash

# Setup Stream Event Id Variable
streamEventId="$1"

# Define the URL for status check
status_url="http://localhost/api/live_events/${streamEventId}/status.json"

# Function to check if the event is no longer running
check_event_status() {
    status_output=$(curl -s $status_url)
    event_status=$(echo $status_output | grep -o '"status": *"[^"]*"' | cut -d '"' -f 4)
    
    if [ "$event_status" != "running" ]; then
        return 0
    else
        return 1
    fi
}

# Perform variable substitution for stop command
stop_output=$(curl -s -X POST http://localhost/api/live_events/${streamEventId}/stop.json -H 'Content-Type: application/xml' -H 'Accept: application/xml' -d '<stop></stop>')

# Check if the stop was successful
if [[ $stop_output == *"Event successfully stopped"* ]]; then
    
    # Loop to check the event status until it's no longer running or max attempts reached
    attempts=0
    max_attempts=5
    while [ $attempts -lt $max_attempts ]; do
        if check_event_status; then
            sleep 1  # Sleep for 1 second
            ((attempts++))
        else
            break
        fi
    done
    
    # Perform variable substitution for delete command
    delete_output=$(curl -s -X DELETE http://localhost/api/live_events/${streamEventId}.json)
    
    # Check if the delete was successful
    if [[ $delete_output != *"Invalid command"* ]]; then
        echo "Stop and Delete Executed"
    fi
fi
