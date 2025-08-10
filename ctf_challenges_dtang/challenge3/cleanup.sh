#!/bin/bash
set -euo pipefail

IMAGE_TAG="ctf-ch3:bashrc-backdoor"
CONTAINER_NAME="challenge3"
BUILD_DIR="$(dirname "$0")/.build"

echo "[*] Stopping and removing container (if present)..."
docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true

echo "[*] Removing image ${IMAGE_TAG} (if present)..."
docker rmi "$IMAGE_TAG" >/dev/null 2>&1 || true

echo "[*] Cleaning local build artifacts..."
rm -rf "$BUILD_DIR"

echo "[+] Cleaned Challenge 3."
