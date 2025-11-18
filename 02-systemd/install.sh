#!/bin/bash
set -e

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Disabling NetworkManager-wait-online.service..."
sudo systemctl disable NetworkManager-wait-online.service || true

echo "Stowing systemd configs"
cd "$MODULE_DIR"
sudo stow --target=/ --dir=. dotfiles

echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

echo "Systemd module installed!"
echo "Note: apt-daily.timer has been configured with custom timing."
