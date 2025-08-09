    #!/usr/bin/env bash
    set -euo pipefail
    IMG="ctf_ch2_fragments"
    out="$(docker run --rm -i "$IMG" bash -lc 'python3 - <<PY
import os, re
frags=[None]*10
for name in os.listdir("/data"):
    with open(os.path.join("/data",name),"r") as f:
        m=re.search(r"{fragment(\d+):(.+?)}", f.read())
        if m:
            frags[int(m.group(1))-1]=m.group(2)
print("".join(frags))
PY')"
    echo "Solver output: $out"
    expected="fbujm38@db"
    [[ "$out" == "$expected" ]] && echo "Challenge 2: PASS" || (echo "Challenge 2: FAIL (expected $expected)" >&2; exit 1)
