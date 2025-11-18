#!/bin/bash
set -e

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GO_VERSION="1.25.4"
ARCH="amd64"

if command -v go &> /dev/null; then
    CURRENT_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
    echo "Go is already installed (version: $CURRENT_VERSION)"
    read -p "Do you want to reinstall Go $GO_VERSION? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Skipping Go installation..."
        cd "$MODULE_DIR"
        stow --target="$HOME" --dir=. dotfiles
        echo "Go module configured!"
        exit 0
    fi
fi

echo "Downloading Go ${GO_VERSION}..."
cd /tmp
wget "https://go.dev/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz"

echo "Installing Go to /usr/local..."
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-${ARCH}.tar.gz"
rm "go${GO_VERSION}.linux-${ARCH}.tar.gz"

echo "Creating Go workspace..."
mkdir -p "$HOME/go/bin"

echo "Stowing dotfiles..."
cd "$MODULE_DIR"
stow --target="$HOME" --dir=. dotfiles

source ~/.profile

echo "Go module installed!"
echo "Go version: $(go version)"
