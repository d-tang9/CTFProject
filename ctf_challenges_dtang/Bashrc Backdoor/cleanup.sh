#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="ctf-bashrc-backdoor:latest"

# Stop any containers from this image (if you started one detached)
for c in $(docker ps -aq --filter "ancestor=$IMAGE_NAME"); do
  docker rm -f "$c" >/dev/null || true
done

echo "[*] Removing staged files..."
rm -f "$HERE/Dockerfile" "$HERE/flag.txt"
rm -f "$HERE/app/.bashrc" "$HERE/app/root.bashrc"
rmdir "$HERE/app" 2>/dev/null || true

echo "[*] Removing Docker image..."
docker image rm -f "$IMAGE_NAME" >/dev/null 2>&1 || true
echo "[+] Cleanup complete."
