#!/usr/bin/env bash
set -euo pipefail
IMAGE="challenge10:latest"
CONTAINER="challenge10"

docker rm -f "$CONTAINER" >/dev/null 2>&1 || true
docker rmi "$IMAGE" >/dev/null 2>&1 || true
rm -rf app

echo "[+] Cleaned Challenge 10."
