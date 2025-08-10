#!/usr/bin/env bash
set -euo pipefail

IMAGE="${IMAGE:-challenge2-fragments:latest}"
NAME="${NAME:-challenge2-fragments}"
EXPECTED="fbujm38@db"

# ---------- helpers ----------
image_exists() { docker image inspect "$1" >/dev/null 2>&1; }
container_exists() { docker ps -a --format '{{.Names}}' | grep -Fxq "$1"; }
container_running() { docker ps --format '{{.Names}}' | grep -Fxq "$1"; }

require() {
  command -v "$1" >/dev/null || { echo "Missing dependency: $1" >&2; exit 1; }
}

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
    echo "[*] Image not found. Building with ./build.sh ..."
    bash ./build.sh
  else
    echo "Image $IMAGE not present and build.sh missing." >&2
    exit 1
  fi
fi

# ---------- ensure container ----------
STARTED_NEW=false
if ! container_exists "$NAME"; then
  echo "[*] Creating container: $NAME"
  # Create a persistent container. We don't care what the image CMD is;
  # we will exec into it. If CMD is 'bash' it'll exit unless -d, if it's
  # 'sleep infinity' it will just idle—either way, we start it detached.
  docker create --name "$NAME" -w /home/ctfuser "$IMAGE" >/dev/null
  STARTED_NEW=true
fi

if ! container_running "$NAME"; then
  echo "[*] Starting container: $NAME"
  docker start "$NAME" >/dev/null
  STARTED_NEW=true
fi

# ---------- solve inside container ----------
# Works for both layouts; our Challenge 2 build used /opt/data
# If you changed the path, set DATA_DIR env before running.
DATA_DIR="${DATA_DIR:-/opt/data}"

out="$(exec_in "
  set -euo pipefail
  if [ ! -d '$DATA_DIR' ]; then
    echo 'FAILED: data dir not found: $DATA_DIR' >&2; exit 2
  fi
  mapfile -t parts < <(
    grep -Rho '{fragment[0-9]\\+:[^}]}' '$DATA_DIR' 2>/dev/null |
    sed -E 's/.*{fragment([0-9]+):([^}]+)}/\\1 \\2/' |
    sort -n |
    awk '{print \$2}'
  )
  printf '%s' \"\${parts[@]}\"
")"

echo "Solver output: $out"
if [[ "$out" == "$EXPECTED" ]]; then
  echo "Challenge 2: PASS"
else
  echo "Challenge 2: FAIL (expected $EXPECTED)" >&2
  # If we created/started a container just for this run, keep it running for manual validation.
  exit 1
fi

# ---------- optional: tidy brand-new container ----------
# If you want the container only for validation, uncomment below to stop it when newly started.
# if [[ "$STARTED_NEW" == "true" ]]; then
#   echo "[*] Stopping container $NAME"
#   docker stop "$NAME" >/dev/null || true
# fi
