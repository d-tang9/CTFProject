#!/usr/bin/env bash
set -euo pipefail
IMG="ctf_ch3_bashrc"
cname="c3_run_$$"
docker run -d --rm --name "$cname" "$IMG" >/dev/null

# Trigger a *login* shell; with .bash_profile present, it will source .bashrc
docker exec -u ctfuser "$cname" bash -l -c 'true' >/dev/null 2>&1 || true

# Brief retry loop in case the copy is slightly delayed
out=""
for i in {1..10}; do
  out="$(docker exec -u ctfuser "$cname" bash -lc 'cat /tmp/.cachefile' 2>/dev/null || true)"
  [ -n "$out" ] && break
  sleep 0.2
done

echo "Solver output: $out"
expected="flag{bashrc_backdoor}"
docker stop "$cname" >/dev/null
[[ "$out" == "$expected" ]] && echo "Challenge 3: PASS" || (echo "Challenge 3: FAIL (expected $expected)" >&2; exit 1)
