#!/usr/bin/env bash
set -euo pipefail
docker rmi -f ctf_ch10_suid >/dev/null 2>&1 || true
rm -rf build_ctx
echo "Cleaned Challenge 10."
