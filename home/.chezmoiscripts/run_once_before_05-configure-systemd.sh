#!/bin/bash
set -e

echo "Disabling NetworkManager-wait-online.service..."
sudo systemctl disable NetworkManager-wait-online.service 2>/dev/null || true

echo "Creating apt-daily.timer override..."
sudo mkdir -p /etc/systemd/system/apt-daily.timer.d
sudo tee /etc/systemd/system/apt-daily.timer.d/override.conf > /dev/null <<EOF
# apt-daily timer configuration override
[Timer]
OnBootSec=15min
OnUnitActiveSec=1d
AccuracySec=1h
RandomizedDelaySec=30min
EOF

echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

echo "Systemd configured!"
echo "Note: apt-daily.timer has been configured with custom timing."
