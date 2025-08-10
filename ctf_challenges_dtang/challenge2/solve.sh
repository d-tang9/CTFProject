#!/usr/bin/env bash
set -euo pipefail

# Config
IMAGE="${IMAGE:-challenge2-fragments:latest}"
NAME="${NAME:-challenge2-fragments}"
EXPECTED="fbujm38@db"
HOME_DIR="/home/ctfuser"

# ---------- helpers ----------
require() { command -v "$1" >/dev/null || { echo "Missing $1" >&2; exit 1; }; }
image_exists() { docker image inspect "$1" >/dev/null 2>&1; }
container_exists() { docker ps -a --format '{{.Names}}' | grep -Fxq "$1"; }
container_running() { docker ps --format '{{.Names}}' | grep -Fxq "$1"; }

exec_in() {
  # prefer bash, fallback to sh
  if docker exec "$NAME" bash -lc 'true' >/dev/null 2>&1; then
    docker exec "$NAME" bash -lc "$1"
  else
    docker exec "$NAME" sh -lc "$1"
  fi
}

# ---------- checks ----------
require docker

echo "[*] Ensuring image present: $IMAGE"
if ! image_exists "$IMAGE"; then
  if [[ -f ./build.sh ]]; then
    echo "[*] Building image..."
    bash ./build.sh
  else
    echo "Image $IMAGE not present and build.sh missing." >&2
    exit 1
  fi
fi

# ---------- ensure persistent container ----------
if ! container_exists "$NAME"; then
  echo "[*] Creating container: $NAME"
  # Create detached container; CMD can be bash or sleep infinity — we exec anyway.
  docker create --name "$NAME" -w "$HOME_DIR" "$IMAGE" >/dev/null
fi

if ! container_running "$NAME"; then
  echo "[*] Starting container: $NAME"
  docker start "$NAME" >/dev/null
fi

# ---------- run solver inside container ----------
out="$(exec_in "
  set -euo pipefail
  cd '$HOME_DIR'
  # Parse {fragmentN:X} using awk only (BusyBox/GNU friendly).
  # Use find to avoid glob errors.
  find . -maxdepth 1 -type f -name '*.txt' -print0 \
    | xargs -0 awk '{
        if (match(\$0, /\\{fragment([0-9]+):([^}]+)\\}/, m)) {
          print m[1], m[2]
        }
      }' \
    | sort -n \
    | awk '{print \$2}' \
    | tr -d '\n'
")"

echo "Solver output: $out"
if [[ "$out" == "$EXPECTED" ]]; then
  echo "Challenge 2: PASS"
else
  echo "Challenge 2: FAIL (expected $EXPECTED)" >&2
  exit 1
fi

# Container is left running for manual play.
