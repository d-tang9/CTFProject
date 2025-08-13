#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="challenge4"
TAG="latest"

# Stop and remove any leftover containers named challenge4 (best-effort)
if docker ps -a --format '{{.Names}}' | grep -q "^challenge4$"; then
  docker rm -f challenge4 >/dev/null 2>&1 || true
fi

# Remove image
if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^${IMAGE_NAME}:${TAG}$"; then
  docker rmi -f "${IMAGE_NAME}:${TAG}" || true
fi

# Remove build context folder
rm -rf "$(pwd)/challenge4"

echo "Cleanup complete."
