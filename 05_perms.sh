#!/usr/bin/env bash
# 05_perms.sh — understand PATH order and file locations
set -Eeuo pipefail

printf "PATH=%s\n" "$PATH"
ls -ld /usr/local/bin /usr/bin 2>/dev/null || true

echo
echo "== which binary runs? =="
type -a echo
command -v echo

echo
echo "== create ~/bin/hello and put it first in PATH =="
mkdir -p "$HOME/bin"
printf '#!/usr/bin/env bash\necho "hello from $HOME/bin/hello"\n' > "$HOME/bin/hello"
chmod +x "$HOME/bin/hello"
export PATH="$HOME/bin:$PATH"
type -a hello
hello

echo
echo "== attempting to install to /usr/local/bin without sudo (should fail) =="
printf '#!/usr/bin/env bash\necho hello from /usr/local/bin/hello\n' > /tmp/hello_root
chmod +x /tmp/hello_root
set +e
cp /tmp/hello_root /usr/local/bin/hello
echo "exit code: $?"
set -e
echo "If you want to install it: sudo cp /tmp/hello_root /usr/local/bin/hello && hello"
