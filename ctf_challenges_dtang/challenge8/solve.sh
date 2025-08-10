#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="challenge8"

if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "Container ${CONTAINER_NAME} is not running. Start it first (./build.sh)." >&2
  exit 1
fi

# Extract text inside PWD=[...]
PW=$(
  docker exec -i "${CONTAINER_NAME}" bash -lc '
    strings ~/checkpass |
    grep -ao "PWD=\[[^]]\+\]" |
    head -n1 |
    sed "s/^PWD=\[//; s/\]$//"
  '
)

if [[ -z "${PW}" ]]; then
  echo "Failed to extract password from binary." >&2
  exit 2
fi

OUTPUT=$(docker exec -i "${CONTAINER_NAME}" bash -lc "cd ~ && printf '%s\n' \"${PW}\" | ./checkpass")
echo "${OUTPUT}"

if grep -q 'flag{' <<< "${OUTPUT}"; then
  echo "[OK] Validation succeeded."
  exit 0
else
  echo "[FAIL] Validation did not return a flag."
  exit 3
fi
