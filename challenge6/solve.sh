#!/usr/bin/env bash
set -euo pipefail
IMG="ctf_ch6_hidden"
out="$(docker run --rm "$IMG" sh -lc 'for f in *; do strings "$f" | grep -m1 "{flag" && break; done')"
echo "Solver output: $out"
expected="{flag_hidden_here}"
[[ "$out" == "$expected" ]] && echo "Challenge 6: PASS" || (echo "Challenge 6: FAIL (expected $expected)" >&2; exit 1)
