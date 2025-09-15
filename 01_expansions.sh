#!/usr/bin/env bash
# 01_expansions.sh — demo bash expansions and quoted vs unquoted here-docs
set -Eeuo pipefail

echo "== Unquoted here-doc (EXPANDS variables, command subs, ~, globs) =="
FOO="world"
cat <<EOF > /tmp/expand_unquoted.txt
hello $FOO
today is $(date +%F)
home is ~
files matching *.sh here:  *.sh
EOF
cat /tmp/expand_unquoted.txt

echo
echo "== Quoted here-doc (LITERAL text; no expansion) =="
cat <<'EOF' > /tmp/expand_quoted.txt
hello $FOO
today is $(date +%F)
home is ~
files matching *.sh here:  *.sh
EOF
cat /tmp/expand_quoted.txt

echo
echo "== Defaulting: unset vs empty with :- and - =="
unset BAR || true
printf "BAR (unset):  A:%s  B:%s\n" "${BAR:-default}" "${BAR-default}"
BAR=""
printf "BAR (empty):  A:%s  B:%s\n" "${BAR:-default}" "${BAR-default}"

echo
echo "Files created:"
ls -l /tmp/expand_unquoted.txt /tmp/expand_quoted.txt
