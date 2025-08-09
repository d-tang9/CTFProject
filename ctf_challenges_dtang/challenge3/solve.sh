#!/usr/bin/env bash
set -euo pipefail
IMG="ctf_ch3_bashrc"
cname="c3_run_$$"
docker run -d --rm --name "$cname" "$IMG" >/dev/null
out="$(docker exec -u ctfuser "$cname" bash -l -c 'exit' >/dev/null 2>&1 || true; docker exec -u ctfuser "$cname" bash -lc 'cat /tmp/.cachefile')"
echo "Solver output: $out"
expected="flag{bashrc_backdoor}"
docker stop "$cname" >/dev/null
[[ "$out" == "$expected" ]] && echo "Challenge 3: PASS" || (echo "Challenge 3: FAIL (expected $expected)" >&2; exit 1)
