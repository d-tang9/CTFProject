#!/usr/bin/env bash
set -euo pipefail
IMG="ctf_ch7_time"
out="$(docker run --rm -i "$IMG" bash -lc 'printf "#!/usr/bin/env bash\necho 04:00\n" > date && chmod +x date && PATH=.:$PATH ./check_flag.sh')"
echo "Solver output: $out"
expected="flag{time_unlock_0400}"
[[ "$out" == "$expected" ]] && echo "Challenge 7: PASS" || (echo "Challenge 7: FAIL (expected $expected)" >&2; exit 1)
