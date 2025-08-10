#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="challenge3_bashrc_backdoor:latest"

echo "[*] Removing staged files..."
rm -f "$HERE/Dockerfile"
rm -f "$HERE/flag.txt"
rm -f "$HERE/entrypoint.sh"
rm -f "$HERE/app/.bashrc"
rm -f "$HERE/app/profile.d/leak.sh"
rmdir "$HERE/app/profile.d" 2>/dev/null || true
rmdir "$HERE/app" 2>/dev/null || true

echo "[*] Removing Docker image (if present)..."
docker image rm -f "$IMAGE_NAME" >/dev/null 2>&1 || true

echo "[+] Cleanup complete."
