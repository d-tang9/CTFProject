#!/bin/bash
set -euo pipefail

CONTAINER_NAME="challenge3"

# Trigger a login shell in the container so ~/.bashrc runs
echo "[*] Triggering login shell to execute the .bashrc backdoor..."
docker exec -u ctfuser "$CONTAINER_NAME" bash -lc 'true' >/dev/null

# The backdoor copies the flag to /tmp/.cachefile
echo "[*] Reading copied flag from /tmp/.cachefile..."
docker exec -u ctfuser "$CONTAINER_NAME" bash -lc 'cat /tmp/.cachefile'
