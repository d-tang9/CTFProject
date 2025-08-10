#!/usr/bin/env bash
set -euo pipefail
IMAGE_NAME="challenge3_bashrc_backdoor:latest"
NAME="challenge3_run_$RANDOM"

echo "[*] Starting container (root leaks flag, then drops to ctfuser)..."
docker run -d --rm --name "$NAME" "$IMAGE_NAME" >/dev/null

# Give entrypoint a moment to copy the flag
sleep 1

echo -n "Flag: "
docker exec "$NAME" bash -lc 'cat /tmp/.cachefile'

# Clean the running container
docker rm -f "$NAME" >/dev/null
