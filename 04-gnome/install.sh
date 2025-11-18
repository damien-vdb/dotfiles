#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if dconf directory exists
if [[ ! -d "$SCRIPT_DIR/dconf" ]]; then
    echo "Error: $SCRIPT_DIR/dconf directory does not exist"
    exit 1
fi

# Load each dconf file
for conf_file in "$SCRIPT_DIR/dconf"/*.conf; do
    # Skip if no .conf files found
    if [[ ! -f "$conf_file" ]]; then
        echo "No .conf files found in $SCRIPT_DIR/dconf/"
        exit 1
    fi

    # Get the filename without path and extension
    filename=$(basename "$conf_file" .ini)

    # Convert filename back to dconf path by replacing . with /
    # Add leading and trailing slashes
    dconf_path="/${filename//.//}/"

    # Load the dconf entry from the file
    echo "Loading $dconf_path from dconf/${filename}.ini"
    dconf load "$dconf_path" < "$conf_file"

done

echo "Done! All dconf entries have been loaded from $SCRIPT_DIR/dconf/"