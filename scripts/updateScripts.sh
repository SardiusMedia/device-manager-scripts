#!/bin/bash

# Check if all required arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 SOURCE_URL DESTINATION_FOLDER SCRIPT_NAMES"
    exit 1
fi

# Source URL for shell scripts
sourceUrl="$1"

# Destination folder on the Elemental device
destinationFolder="$2"

# Create destination folder if it doesn't exist
mkdir -p "$destinationFolder"

# Script names provided as space-separated list
scriptNames="$3"

# Convert space-separated script names to an array
IFS=' ' read -ra SCRIPT_ARRAY <<< "$scriptNames"

# Loop through the list of script names
for scriptName in "${SCRIPT_ARRAY[@]}"; do
    # Download the script using curl
    curl -o "$destinationFolder/$scriptName" "$sourceUrl/$scriptName"

    # Give execute permission to the downloaded script
    chmod +x "$destinationFolder/$scriptName"

done