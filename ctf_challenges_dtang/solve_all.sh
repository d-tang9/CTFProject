#!/usr/bin/env bash
# solve_all.sh — run each challenge's solver, keep going on failures, print summary
set -u  # keep -u, but DO NOT use -e so we don't exit on first failure
here="$(cd "$(dirname "$0")" && pwd)"

declare -A STATUS
fail_count=0

for d in $(seq 1 10); do
  echo "== Solving challenge $d =="
  if (cd "$here/challenge$d" && ./solve.sh); then
    STATUS[$d]="PASS"
  else
    STATUS[$d]="FAIL"
    fail_count=$((fail_count+1))
  fi
done

echo
echo "==== Summary ===="
for d in $(seq 1 10); do
  printf "Challenge %d: %s\n" "$d" "${STATUS[$d]:-SKIPPED}"
done

# Exit 0 if all passed; 1 if any failed
if [ "$fail_count" -gt 0 ]; then
  echo
  echo "$fail_count challenge(s) failed."
  exit 1
else
  echo
  echo "All challenges passed."
  exit 0
fi
