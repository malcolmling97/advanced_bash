#!/usr/bin/env bash
# 04_old_vs_new.sh — show why 'sudo tee' is preferred for root-owned files
set -Eeuo pipefail

echo "This will try writing under /etc. You'll likely be prompted for sudo once."
sudo -v

echo
echo "== WRONG pattern: sudo echo ... > /etc/xxx (redirection happens before sudo) =="
set +e
sudo echo "hello via sudo echo" > /etc/tee_demo_root.txt
echo "exit code: $?"
set -e

echo
echo "== RIGHT pattern: pipe into sudo tee (tee runs as root) =="
cat <<'EOF' | sudo tee /etc/tee_demo_root.txt >/dev/null
hello via sudo tee
EOF
echo "/etc/tee_demo_root.txt:"
sudo cat /etc/tee_demo_root.txt

echo
echo "Cleanup (optional): sudo rm -f /etc/tee_demo_root.txt"
