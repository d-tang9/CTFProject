#!/usr/bin/env bash
set -euo pipefail
docker rmi -f challenge2-fragments:latest >/dev/null 2>&1 || true
rm -rf build_ctx
echo "Cleaned Challenge 2."
