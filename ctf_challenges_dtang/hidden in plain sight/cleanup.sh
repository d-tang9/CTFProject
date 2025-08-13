#!/usr/bin/env bash
set -euo pipefail
CONTAINER_NAME="challenge6"
IMAGE_NAME="challenge6:latest"

docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
docker rmi "$IMAGE_NAME" >/dev/null 2>&1 || true
rm -f Dockerfile flag.txt >/dev/null 2>&1 || true

echo "[*] Cleaned up Challenge 6."
