#!/usr/bin/env bash
# Proof-of-concept solve: shows the leaked flag produced by the backdoored .bashrc
set -euo pipefail

IMAGE_NAME="challenge3_bashrc_backdoor:latest"

# Start a container; interactive bash triggers .bashrc, which copies the flag
# Then print the leaked flag from /tmp/.cachefile
echo "[*] Launching container and reading leaked flag..."
docker run --rm "$IMAGE_NAME" bash -ic 'sleep 0.2; echo -n "Flag: "; cat /tmp/.cachefile'
