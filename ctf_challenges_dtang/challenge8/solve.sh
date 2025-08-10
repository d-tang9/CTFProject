#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="challenge8"

# Ensure container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "Container ${CONTAINER_NAME} is not running. Start it first (./build.sh)." >&2
  exit 1
fi

# Extract the password from the binary using the breadcrumb marker
PW=$(docker exec -i "${CONTAINER_NAME}" bash -lc \
  "strings /home/ctfuser/checkpass | grep -o 'PWD=.*' | head -n1 | cut -d= -f2")

if [[ -z "${PW}" ]]; then
  echo "Failed to extract password from binary." >&2
  exit 2
fi

# Feed the password to the program and capture output
OUTPUT=$(docker exec -i "${CONTAINER_NAME}" bash -lc "cd ~ && printf '%s\n' \"${PW}\" | ./checkpass")

echo "${OUTPUT}"

# Basic success check
if grep -q 'flag{' <<< "${OUTPUT}"; then
  echo "[OK] Validation succeeded."
  exit 0
else
  echo "[FAIL] Validation did not return a flag."
  exit 3
fi
