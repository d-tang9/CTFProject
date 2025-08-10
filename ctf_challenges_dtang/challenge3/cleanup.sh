#!/bin/bash
set -e

IMAGE="challenge3"
CONTAINER="challenge3"

echo "[*] Removing container and image..."
docker rm -f $CONTAINER >/dev/null 2>&1 || true
docker rmi $IMAGE >/dev/null 2>&1 || true
echo "[+] Cleaned Challenge 3."
