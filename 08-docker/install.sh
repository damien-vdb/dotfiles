#!/bin/bash
set -e

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing Docker via official script..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
    sudo sh /tmp/get-docker.sh
    rm /tmp/get-docker.sh
else
    echo "Docker already installed, skipping..."
fi

echo "Adding user to docker group..."
sudo usermod -aG docker $USER
sudo newgrp docker

echo "Enabling Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

echo "Copying daemon.json to /etc/docker/..."
sudo mkdir -p /etc/docker
sudo cp "$MODULE_DIR/daemon.json" /etc/docker/daemon.json
sudo systemctl restart docker

echo "Docker module installed!"
echo "Note: You may need to log out and back in for docker group to take effect."
