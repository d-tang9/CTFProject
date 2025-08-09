#!/usr/bin/env bash
set -euo pipefail
IMG="ctf_ch8_rev_go"
out="$(docker run --rm "$IMG" bash -lc 'strings ./checkpass | grep -E -m1 "[A-Za-z0-9@]{6,}" | head -n 1 | xargs -I{} bash -lc "echo \"{}\" | ./checkpass"')"
echo "Solver output: $out"
expected="flag{re_strings_go}"
[[ "$out" == "$expected" ]] && echo "Challenge 8: PASS" || (echo "Challenge 8: FAIL (expected $expected)" >&2; exit 1)
