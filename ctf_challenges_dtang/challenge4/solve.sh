#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="challenge4"
TAG="latest"

# Run once, print the flag, and remove the container
echo "Reading flag from world-readable backup..."
docker run --rm "${IMAGE_NAME}:${TAG}" bash -lc 'cat /var/backups/flag_backup.txt' | sed 's/^/Flag: /'
