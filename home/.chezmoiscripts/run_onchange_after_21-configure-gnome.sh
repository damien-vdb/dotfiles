#!/bin/bash
set -e

DCONF_DIR="$HOME/.config/dconf"

if [[ ! -d "$DCONF_DIR" ]]; then
    echo "dconf directory not found at $DCONF_DIR"
    exit 1
fi

echo "Loading GNOME dconf settings..."

# Load each dconf file
for conf_file in "$DCONF_DIR"/*.ini; do
    # Skip if no .conf files found
    if [[ ! -f "$conf_file" ]]; then
        echo "No .conf files found in $DCONF_DIR/"
        exit 1
    fi

    # Get the filename without path and extension
    filename=$(basename "$conf_file" .ini)

    # Convert filename back to dconf path by replacing . with /
    # Add leading and trailing slashes
    dconf_path="/${filename//.//}/"

    # Load the dconf entry from the file
    echo "Loading $dconf_path from ${filename}.conf"
    dconf load "$dconf_path" < "$conf_file"
done

echo "GNOME dconf settings loaded!"
