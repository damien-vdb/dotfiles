#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create the output directory if it doesn't exist
mkdir -p "$SCRIPT_DIR/dconf"

# Read the dconf-folders.txt file
while IFS= read -r entry; do
    # Skip empty lines
    if [[ -z "$entry" ]]; then
        continue
    fi

    # Remove leading and trailing whitespace
    entry=$(echo "$entry" | xargs)

    # Skip if still empty after trimming
    if [[ -z "$entry" ]]; then
        continue
    fi

    # Create filename by replacing / with .
    # Remove leading and trailing slashes, then replace remaining / with .
    filename=$(echo "$entry" | sed 's:^/::' | sed 's:/$::' | tr '/' '.')

    # Dump the dconf entry to the file
    echo "Dumping $entry to dconf/${filename}.conf"
    dconf dump "$entry" > "$SCRIPT_DIR/dconf/${filename}.ini"

done < "$SCRIPT_DIR/dconf-folders.txt"

echo "Done! All dconf entries have been dumped to $SCRIPT_DIR/dconf/"