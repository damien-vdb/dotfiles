#!/bin/bash
set -e

if [ -f /opt/zen/zen ]; then
    echo "Zen browser is already installed"
    exit 0
fi

cd /tmp
echo "Downloading Zen browser..."
if ! wget --tries=3 --timeout=30 https://github.com/zen-browser/desktop/releases/latest/download/zen.linux-x86_64.tar.xz; then
    echo "Error: Failed to download Zen browser"
    exit 1
fi

if [ ! -f zen.linux-x86_64.tar.xz ]; then
    echo "Error: Download file not found"
    exit 1
fi

echo "Extracting Zen browser..."
if ! tar -xJf zen.linux-x86_64.tar.xz; then
    echo "Error: Failed to extract Zen browser archive"
    rm -f zen.linux-x86_64.tar.xz
    exit 1
fi

if [ ! -d zen ]; then
    echo "Error: Extracted zen directory not found"
    rm -f zen.linux-x86_64.tar.xz
    exit 1
fi
sudo mv zen /opt/.
sudo chmod o+rx /opt/zen
sudo ln -sf /opt/zen/zen /usr/local/bin/zen
rm -f zen.linux-x86_64.tar.xz

echo "Removing xdg-desktop-portal-gnome to fix slow browser startup..."
sudo apt remove -y xdg-desktop-portal-gnome 2>/dev/null || true

echo "Zen browser installed!"
echo "If running with a NVIDIA GPU, look at the VAAPI driver at https://github.com/elFarto/nvidia-vaapi-driver"
