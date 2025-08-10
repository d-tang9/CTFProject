#!/usr/bin/env bash
set -euo pipefail

IMAGE="challenge1:latest"

# Stop and remove any containers derived from the image
# (best-effort, ignore errors if none exist)
docker ps -a --filter "ancestor=$IMAGE" --format '{{.ID}}' | xargs -r docker rm -f

# Remove the image
docker rmi -f "$IMAGE" >/dev/null 2>&1 || true

# Remove build context
rm -rf "$(cd "$(dirname "$0")" && pwd)/build_ctx"

echo "Cleaned Challenge 1."
