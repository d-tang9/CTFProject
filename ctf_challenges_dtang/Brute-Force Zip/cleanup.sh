#!/usr/bin/env bash
set -euo pipefail

IMAGE="challenge1:latest"

docker ps -a --filter "ancestor=$IMAGE" --format '{{.ID}}' | xargs -r docker rm -f

docker rmi -f "$IMAGE" >/dev/null 2>&1 || true

rm -rf "$(cd "$(dirname "$0")" && pwd)/build_ctx"

echo "Cleaned Challenge 1."
