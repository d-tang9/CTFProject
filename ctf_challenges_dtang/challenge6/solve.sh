#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="challenge6"
EXPECTED_FLAG="flag{hidden_in_plain_sight}"

# Simple strategy:
# 1) Look for hex-looking files in /home/ctfuser
# 2) Run strings and grep for the flag pattern
FOUND_FLAG="$(
  docker exec -i "$CONTAINER_NAME" sh -lc '
    cd /home/ctfuser || exit 1
    # Scan reasonable-size files for classic flag pattern
    for f in * .* 2>/dev/null; do
      [ -f "$f" ] || continue
      # Use strings; grep for "flag{"
      strings "$f" 2>/dev/null | grep -E "flag\{[[:print:]]+\}" || true
    done | head -n1
  ' | tr -d "\r"
)"

if [ -z "$FOUND_FLAG" ]; then
  echo "[-] No flag found via strings search."
  exit 2
fi

echo "[+] Found: $FOUND_FLAG"

if [ "$FOUND_FLAG" = "$EXPECTED_FLAG" ]; then
  echo "[+] Validation success."
  exit 0
else
  echo "[-] Validation found a flag-like string but it didn't match EXPECTED_FLAG."
  exit 3
fi
