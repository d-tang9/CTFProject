#!/usr/bin/env bash
set -euo pipefail

IMAGE="dtang9/challenge1-brute-force-zip:latest"

# Run a one-shot container that brute-forces using unzip and the provided wordlist
out="$(
  docker run --rm -w /home/ctfuser "$IMAGE" bash -lc '
    set -euo pipefail
    # Try each password; stop on first success and print the flag
    while IFS= read -r pw; do
      if unzip -P "$pw" -o secret.zip >/dev/null 2>&1; then
        cat flag.txt
        exit 0
      fi
    done < wordlist.txt
    echo "FAILED" >&2
    exit 2
  '
)"

echo "Solver output: $out"
expected="flag{bruteforce_zip}"
if [[ "$out" == "$expected" ]]; then
  echo "Challenge 1: PASS"
else
  echo "Challenge 1: FAIL (expected $expected)" >&2
  exit 1
fi
