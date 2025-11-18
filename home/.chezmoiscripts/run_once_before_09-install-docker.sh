#!/bin/bash
set -e

if command -v docker &> /dev/null; then
    echo "Docker is already installed ($(docker --version))"
else
    echo "Installing Docker via official script..."
    curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
    sudo sh /tmp/get-docker.sh
    rm /tmp/get-docker.sh

    echo "Enabling Docker service..."
    sudo systemctl enable docker
    sudo systemctl start docker
fi

echo "Adding user to docker group..."
sudo usermod -aG docker $USER || true

echo "Configuring Docker daemon..."
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json > /dev/null <<'EOF'
{
  "log-driver": "local",
  "log-opts": {
    "max-size": "10m"
  }
}
EOF

if command -v docker &> /dev/null && systemctl is-active --quiet docker; then
    echo "Restarting Docker service..."
    sudo systemctl restart docker
fi

echo "Docker installed!"
