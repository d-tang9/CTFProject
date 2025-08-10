#!/usr/bin/env bash
# Remove all files created by build.sh and the Docker artifacts.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="challenge3_bashrc_backdoor:latest"

echo "[*] Removing staged files..."
rm -f "$HERE/Dockerfile"
rm -f "$HERE/flag.txt"
rm -f "$HERE/app/.bashrc"
rmdir "$HERE/app" 2>/dev/null || true

echo "[*] Removing Docker image (if present)..."
docker image rm -f "$IMAGE_NAME" >/dev/null 2>&1 || true

echo "[+] Cleanup complete."
