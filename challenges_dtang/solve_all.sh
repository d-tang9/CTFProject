#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
for d in $(seq 1 10); do
  echo "== Solving challenge $d =="
  (cd "$here/challenge$d" && ./solve.sh)
done
