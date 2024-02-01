#!/bin/bash

# Check if all required arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 SOURCE_URL DESTINATION_FOLDER SCRIPT_NAMES"
    exit 1
fi

# Source URL for shell scripts
SOURCE_URL="$1"

# Destination folder on the Elemental device
DESTINATION_FOLDER="$2"

# Create destination folder if it doesn't exist
mkdir -p "$DESTINATION_FOLDER"

# Script names provided as space-separated list
SCRIPT_NAMES="$3"

# Convert space-separated script names to an array
IFS=' ' read -ra SCRIPT_ARRAY <<< "$SCRIPT_NAMES"

# Loop through the list of script names
for SCRIPT_NAME in "${SCRIPT_ARRAY[@]}"; do
    # Download the script using curl
    curl -O "$DESTINATION_FOLDER/$SCRIPT_NAME" "$SOURCE_URL/$SCRIPT_NAME"

done