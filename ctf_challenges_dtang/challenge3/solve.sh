#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="challenge3_bashrc_backdoor:latest"

echo "[*] Launching container (ctfuser by default) and reading leaked flag..."
# The entrypoint already starts a login shell (which triggers the leak),
# so we can exec a one-shot command to read the cachefile.
docker run --rm --entrypoint bash "$IMAGE_NAME" -lc 'sleep 0.5; echo -n "Flag: "; cat /tmp/.cachefile'
