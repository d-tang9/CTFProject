#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="challenge3_bashrc_backdoor:latest"

# Stop any leftover containers from this image
for c in $(docker ps -aq --filter "ancestor=$IMAGE_NAME"); do
  docker rm -f "$c" >/dev/null || true
done

echo "[*] Removing staged files..."
rm -f "$HERE/Dockerfile" "$HERE/flag.txt" "$HERE/entrypoint.sh" "$HERE/app/.bashrc"
rmdir "$HERE/app" 2>/dev/null || true

echo "[*] Removing Docker image..."
docker image rm -f "$IMAGE_NAME" >/dev/null 2>&1 || true
echo "[+] Cleanup complete."
