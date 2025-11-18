#!/bin/bash
set -e

if command -v ghostty &> /dev/null; then
    echo "Ghostty is already installed"
    exit 0
fi

cd /tmp
echo "Installing Ghostty..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"

echo "Ghostty installed!"
