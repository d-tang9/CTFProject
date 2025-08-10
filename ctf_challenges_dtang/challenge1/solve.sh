#!/usr/bin/env bash
set -euo pipefail

IMAGE="dtang9/challenge1-brute-force-zip:latest"
# e.g. IMAGE=repo/name:tag  -> NAME=name
NAME="${NAME:-$(basename "${IMAGE%%:*}")}"

# ---------- helpers ----------
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

# ---------- ensure image ----------
echo "[*] Ensuring image present: $IMAGE"
if ! image_exists "$IMAGE"; then
  docker pull "$IMAGE" >/dev/null
fi

# ---------- ensure container ----------
STARTED_NEW=false
echo "[*] Checking container state: $NAME"
if container_exists "$NAME"; then
  if container_running("$NAME"); then
    echo "    Reusing running container."
  else
    echo "    Removing stopped container and starting fresh."
    docker rm -f "$NAME" >/dev/null
    docker run -d --name "$NAME" "$IMAGE" tail -f /dev/null >/dev/null
    STARTED_NEW=true
  fi
else
  echo "    Starting new container."
  docker run -d --name "$NAME" "$IMAGE" tail -f /dev/null >/dev/null
  STARTED_NEW=true
fi

# Small grace period if freshly started
sleep 1

# ---------- solver logic ----------
echo "[*] Running brute-force solver inside container..."
out="$(exec_in '
  set -euo pipefail
  cd /home/ctfuser
  # Try each password; stop on first success and print the flag
  while IFS= read -r pw; do
    if unzip -P "$pw" -o secret.zip >/dev/null 2>&1; then
      cat flag.txt
      exit 0
    fi
  done < wordlist.txt
  echo FAILED >&2
  exit 2
')"

echo "Solver output: $out"

expected="flag{bruteforce_zip}"
if [[ "$out" == "$expected" ]]; then
  echo "Challenge 1: PASS"
else
  echo "Challenge 1: FAIL (expected $expected)" >&2
  # Cleanup only if we started it
  $STARTED_NEW && docker rm -f "$NAME" >/dev/null || true
  exit 1
fi

# ---------- cleanup ----------
if $STARTED_NEW; then
  echo "[*] Cleaning up container we started: $NAME"
  docker rm -f "$NAME" >/dev/null
else
  echo "[*] Left existing container running: $NAME"
fi
