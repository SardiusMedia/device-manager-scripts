#!/bin/bash

# Setup Stream Event Id Variable
streamEventId="$1"

# Perform variable substitution for stop command
stop_output=$(curl -X POST http://localhost/api/live_events/${streamEventId}/stop.json -H 'Content-Type: application/xml' -H 'Accept: application/xml' -d '<stop></stop>')

# Check if the stop was successful
if [[ $stop_output == *"Event successfully stopped"* ]]; then
    # Perform variable substitution for delete command
    delete_output=$(curl -X DELETE http://localhost/api/live_events/${streamEventId}.json)
    
    # Check if the delete was successful
    if [[ $delete_output == *"Invalid command"* ]]; then
        echo "Stop and Delete Failed"
    else
        echo "Stop and Delete Executed"
    fi
elif [[ $stop_output == *"Invalid command: Live Event "* ]]; then
    # Perform variable substitution for delete command
    delete_output=$(curl -X DELETE http://localhost/api/live_events/${streamEventId}.json)
    
    # Check if the delete was successful
    if [[ $delete_output == *"Invalid command"* ]]; then
        echo "Stop and Delete Failed"
    else
        echo "Stop and Delete Executed"
    fi
else
    echo "Stop and Delete Failed"
fi
