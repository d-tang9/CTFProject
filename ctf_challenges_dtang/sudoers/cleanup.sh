#!/usr/bin/env bash
set -euo pipefail

IMAGE="ctf-challenge5:latest"
CONTAINER="challenge5"

# Stop & remove container if present
if docker ps -a --format '{{.Names}}' | grep -qx "$CONTAINER"; then
  docker rm -f "$CONTAINER" >/dev/null || true
  echo "🧹 Removed container $CONTAINER"
fi

# Remove image if present
if docker images --format '{{.Repository}}:{{.Tag}}' | grep -qx "$IMAGE"; then
  docker rmi "$IMAGE" >/dev/null || true
  echo "🧹 Removed image $IMAGE"
fi
