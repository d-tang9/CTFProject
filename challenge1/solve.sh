    #!/usr/bin/env bash
    set -euo pipefail
    IMG="ctf_ch1_zip"
    out="$(docker run --rm -i "$IMG" bash -lc 'python3 - <<PY
import zipfile, sys
z = zipfile.ZipFile("secret.zip")
with open("wordlist.txt") as f:
    for line in f:
        pw=line.strip().encode()
        try:
            z.extractall(pwd=pw)
            with open("flag.txt") as ff: print(ff.read().strip())
            sys.exit(0)
        except Exception: pass
print("FAILED", file=sys.stderr); sys.exit(2)
PY')"
    echo "Solver output: $out"
    expected="flag{bruteforce_zip}"
    [[ "$out" == "$expected" ]] && echo "Challenge 1: PASS" || (echo "Challenge 1: FAIL (expected $expected)" >&2; exit 1)
