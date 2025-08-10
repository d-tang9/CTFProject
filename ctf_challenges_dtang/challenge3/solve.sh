#!/usr/bin/env bash
set -euo pipefail
IMAGE_NAME="dtang9/challenge3-bashrc-backdoor:latest"
NAME="challenge3-bashrc-backdoor"

echo "[*] Starting container (defaults to ctfuser)..."
docker run -d --rm --name "$NAME" "$IMAGE_NAME" >/dev/null

sleep 1
echo -n "Flag: "
docker exec "$NAME" bash -lc 'cat /tmp/.cachefile'

docker rm -f "$NAME" >/dev/null
