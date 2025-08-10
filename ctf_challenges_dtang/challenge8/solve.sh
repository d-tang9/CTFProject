#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="challenge8"

# ensure container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "Container ${CONTAINER_NAME} is not running. Start it first (./build.sh)." >&2
  exit 1
fi

# extract the password robustly: take first PWD=..., then strip everything after the first non-password char
PW=$(
  docker exec -i "${CONTAINER_NAME}" bash -lc '
    strings ~/checkpass |
    awk -F"PWD=" "/PWD=/{print \$2; exit}" |
    tr -d "\r\n" |
    sed "s/[^[:print:]]//g"
  '
)

if [[ -z "${PW}" ]]; then
  echo "Failed to extract password from binary." >&2
  exit 2
fi

# run the binary with the cleaned password
OUTPUT=$(docker exec -i "${CONTAINER_NAME}" bash -lc "cd ~ && printf '%s\n' '${PW}' | ./checkpass")
echo "${OUTPUT}"

if grep -q 'flag{' <<< "${OUTPUT}"; then
  echo "[OK] Validation succeeded."
  exit 0
else
  echo "[FAIL] Validation did not return a flag."
  exit 3
fi
