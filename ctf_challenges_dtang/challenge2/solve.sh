#!/usr/bin/env bash
set -euo pipefail

IMAGE="${IMAGE:-challenge2-fragments:latest}"
NAME="${NAME:-challenge2-fragments}"
EXPECTED="fbujm38@db"

image_exists() { docker image inspect "$1" >/dev/null 2>&1; }
container_exists() { docker ps -a --format '{{.Names}}' | grep -Fxq "$1"; }
container_running() { docker ps --format '{{.Names}}' | grep -Fxq "$1"; }

exec_in() {
  if docker exec "$NAME" bash -lc 'true' >/dev/null 2>&1; then
    docker exec "$NAME" bash -lc "$1"
  else
    docker exec "$NAME" sh -lc "$1"
  fi
}

command -v docker >/dev/null || { echo "Docker not found" >&2; exit 1; }

echo "[*] Ensuring image present: $IMAGE"
if ! image_exists "$IMAGE"; then
  [[ -f ./build.sh ]] || { echo "Image missing and no build.sh." >&2; exit 1; }
  echo "[*] Building image..."
  bash ./build.sh
fi

if ! container_exists "$NAME"; then
  echo "[*] Creating container: $NAME"
  docker create --name "$NAME" -w /home/ctfuser "$IMAGE" >/dev/null
fi
if ! container_running "$NAME"; then
  echo "[*] Starting container: $NAME"
  docker start "$NAME" >/dev/null
fi

# If you used the Python-slim variant earlier, set DATA_DIR=/data
DATA_DIR="${DATA_DIR:-/opt/data}"

out="$(
  exec_in "
    set -euo pipefail
    if [ ! -d '$DATA_DIR' ]; then
      echo 'FAILED' >&2; exit 2
    fi
    # Extract '{fragmentN:X}' as 'N X', sort by N, then print Xs without newlines
    awk '
      { if (match(\$0, /\\{fragment([0-9]+):([^}]+)\\}/, m)) { print m[1], m[2] } }
    ' $DATA_DIR/* 2>/dev/null | sort -n | awk '{print \$2}' | tr -d '\n'
  "
)"

echo "Solver output: $out"
if [[ "$out" == "$EXPECTED" ]]; then
  echo "Challenge 2: PASS"
else
  echo "Challenge 2: FAIL (expected $EXPECTED)" >&2
  exit 1
fi
