#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="challenge6"
EXPECTED_FLAG="flag{hidden_in_plain_sight}"

# Search for a flag-like string via strings
FOUND_FLAG="$(
  docker exec -i "$CONTAINER_NAME" bash -lc '
    cd /home/ctfuser || exit 1
    for f in * .* 2>/dev/null; do
      [ -f "$f" ] || continue
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
  echo "[-] Flag-like string found but did not match EXPECTED_FLAG."
  exit 3
fi
