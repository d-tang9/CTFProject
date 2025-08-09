#!/usr/bin/env bash
set -euo pipefail
IMG="ctf_ch4_backup"
out="$(docker run --rm "$IMG" bash -lc 'cat /var/backups/flag_backup.txt')"
echo "Solver output: $out"
expected="flag{backup_perms_leak}"
[[ "$out" == "$expected" ]] && echo "Challenge 4: PASS" || (echo "Challenge 4: FAIL (expected $expected)" >&2; exit 1)
