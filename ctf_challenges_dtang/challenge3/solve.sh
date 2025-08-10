#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME="dtang9/challenge3-bashrc-backdoor:latest"
NAME="challenge3-bashrc-backdoor"

# --- helpers ---
image_exists() {
  docker image inspect "$1" >/dev/null 2>&1
}

container_exists() {
  docker ps -a --format '{{.Names}}' | grep -Fxq "$1"
}

container_running() {
  docker ps --format '{{.Names}}' | grep -Fxq "$1"
}

STARTED_NEW=false

echo "[*] Ensuring image is present..."
if ! image_exists "$IMAGE_NAME"; then
  echo "    pulling $IMAGE_NAME ..."
  docker pull "$IMAGE_NAME" >/dev/null
fi

echo "[*] Checking container state for '$NAME'..."
if container_exists "$NAME"; then
  if container_running "$NAME"; then
    echo "    container exists and is RUNNING -> reusing."
  else
    echo "    container exists but is STOPPED -> removing and recreating."
    docker rm -f "$NAME" >/dev/null
    echo "    starting fresh container..."
    docker run -d --rm --name "$NAME" "$IMAGE_NAME" >/dev/null
    STARTED_NEW=true
  fi
else
  echo "    no existing container -> starting new."
  docker run -d --rm --name "$NAME" "$IMAGE_NAME" >/dev/null
  STARTED_NEW=true
fi

# Give it a moment to initialize
sleep 1

echo -n "Flag: "
# Use bash if available; fallback to sh
if docker exec "$NAME" bash -lc 'cat /tmp/.cachefile' >/dev/null 2>&1; then
  docker exec "$NAME" bash -lc 'cat /tmp/.cachefile'
else
  docker exec "$NAME" sh -lc 'cat /tmp/.cachefile'
fi

# Only clean up if we created it; otherwise, leave user’s container alone
if $STARTED_NEW; then
  echo "[*] Cleaning up container '$NAME'..."
  docker rm -f "$NAME" >/dev/null
else
  echo "[*] Left existing container running (no cleanup)."
fi
