#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
"$here/build_all.sh"
"$here/solve_all.sh"
