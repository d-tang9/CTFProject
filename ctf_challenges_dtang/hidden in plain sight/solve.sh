#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="challenge6"
EXPECTED_FLAG="flag{hidden_in_plain_sight}"

# Search all regular files in /home/ctfuser (including dotfiles) for the first flag-looking string
FOUND_FLAG="$(
  docker exec -i "$CONTAINER_NAME" bash -lc '
    cd /home/ctfuser || exit 1
    # strings on dotfiles and normal files; silence errors for non-regular matches
    strings .[!.]* * 2>/dev/null | grep -m1 -E "flag\{[[:print:]]+\}"
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
