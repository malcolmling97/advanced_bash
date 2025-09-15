#!/usr/bin/env bash
# 02_tee.sh — demo how tee writes to file and echoes to stdout
set -Eeuo pipefail

echo "== tee writes to file AND to your terminal =="
cat <<EOF | tee /tmp/tee_demo.txt
line one
line two
EOF
echo "cat /tmp/tee_demo.txt:"; cat /tmp/tee_demo.txt

echo
echo "== silence tee's echo with >/dev/null (file still written) =="
cat <<EOF | tee /tmp/tee_demo_silent.txt >/dev/null
quiet line
EOF
cat /tmp/tee_demo_silent.txt

echo
echo "== append (-a) vs truncate (default) =="
echo first  | tee /tmp/tee_append.txt
echo second | tee -a /tmp/tee_append.txt
cat /tmp/tee_append.txt

echo
echo "== multiple outputs (GNU tee) =="
echo hi | tee /tmp/tee1.txt /tmp/tee2.txt >/dev/null
ls -l /tmp/tee1.txt /tmp/tee2.txt

echo
echo "== directories must exist (expected failure) =="
set +e
cat <<EOF | tee /tmp/does_not_exist/tee_fail.txt >/dev/null
this fails because parent dir is missing
EOF
echo "exit code: $?"
set -e

echo
echo "== create directory first, then it works =="
mkdir -p /tmp/does_exist
echo ok | tee /tmp/does_exist/tee_ok.txt >/dev/null
cat /tmp/does_exist/tee_ok.txt

cat <<'TXT'

STDIN/STDOUT mental model:
[cat here-doc] --(stdout)--> |pipe| --(stdin)--> [tee] --writes--> /tmp/...
                                            \--> (stdout to your terminal)

TXT
