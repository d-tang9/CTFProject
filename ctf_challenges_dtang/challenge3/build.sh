#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

# Fresh build & run
docker rm -f challenge3 >/dev/null 2>&1 || true
docker build -t challenge3 .
docker run -d --name challenge3 challenge3
echo "[+] challenge3 is up."
