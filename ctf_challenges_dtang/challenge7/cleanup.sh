#!/bin/bash
set -euo pipefail

CHAL_NAME="challenge7"
IMG_TAG="ctf-${CHAL_NAME}"

docker rm -f "${CHAL_NAME}" 2>/dev/null || true
docker rmi -f "${IMG_TAG}" 2>/dev/null || true
rm -rf "${CHAL_NAME}" || true

echo "Cleaned up ${CHAL_NAME}."
