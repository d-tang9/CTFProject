#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
for d in $(seq 1 10); do
  echo "== Building challenge $d =="
  (cd "$here/challenge$d" && ./build.sh)
done
