# 06_hello_unit.sh — minimal oneshot unit (EC2/Linux with systemd)

#!/usr/bin/env bash
# 06_hello_unit.sh — create a tiny oneshot systemd unit that writes a file
set -Eeuo pipefail

if ! command -v systemctl >/dev/null 2>&1; then
  echo "systemctl not found (macOS or non-systemd). Run this on a Linux VM/EC2."
  exit 0
fi

sudo -v

cat <<'UNIT' | sudo tee /etc/systemd/system/hello.service >/dev/null
[Unit]
Description=Hello demo

[Service]
Type=oneshot
User=root
ExecStart=/bin/sh -c 'echo "Hello at $(date +%T)" > /tmp/hello_unit.txt'

[Install]
WantedBy=multi-user.target
UNIT

sudo systemctl daemon-reload
sudo systemctl enable --now hello.service
sudo systemctl status hello.service --no-pager
echo
echo "Output file:"
cat /tmp/hello_unit.txt
echo
echo "Re-run with: sudo systemctl start hello.service"
echo "Remove with: sudo systemctl disable --now hello.service && sudo rm -f /etc/systemd/system/hello.service && sudo systemctl daemon-reload"
