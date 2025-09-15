#!/usr/bin/env bash
# 03_unit_dry.sh — write a systemd-like unit file to /tmp (just to inspect format)
set -Eeuo pipefail

cat <<'UNIT' > /tmp/example.service
[Unit]
Description=Example Service (dry run)
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/bin/echo "Hello from unit file"
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
UNIT

echo "== section headers =="
grep -n "^\[" /tmp/example.service || true
echo
echo "== file content =="
sed -n '1,200p' /tmp/example.service
