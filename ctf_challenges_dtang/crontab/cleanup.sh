#!/usr/bin/env bash
set -euo pipefail

IMAGE="challenge9:latest"
CONTAINER="challenge9"

docker rm -f "$CONTAINER" >/dev/null 2>&1 || true
docker rmi -f "$IMAGE" >/dev/null 2>&1 || true

# Optional: clean local build context
rm -rf app
echo "Cleaned up container, image, and build context."
