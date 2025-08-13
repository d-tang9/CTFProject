#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="ctf-challenge8:latest"
CONTAINER_NAME="challenge8"

# Stop & remove container if present
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true
  echo "Removed container ${CONTAINER_NAME}"
fi

# Remove image if present
if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^${IMAGE_NAME}$"; then
  docker rmi "${IMAGE_NAME}" >/dev/null 2>&1 || true
  echo "Removed image ${IMAGE_NAME}"
fi
