#!/usr/bin/env bash
set -euo pipefail

IMAGE="challenge2-fragments:latest"
EXPECTED="fbujm38@db"

# Basic checks
command -v docker >/dev/null || { echo "Docker not found" >&2; exit 1; }
if ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
  if [ -f "./build.sh" ]; then
    echo "[*] Image not found. Building..."
    bash ./build.sh
  else
    echo "Image $IMAGE not present and build.sh missing." >&2
    exit 1
  fi
fi

# Run parser inside the container using bash+grep+sed (no Python needed)
out="$(
  docker run --rm "$IMAGE" bash -lc '
    set -euo pipefail
    mapfile -t parts < <(
      grep -Rho '"'"'{fragment[0-9]\+:[^}]}'"'"' /opt/data |
      sed -E '"'"'s/.*{fragment([0-9]+):([^}]+)}/\1 \2/'"'"' |
      sort -n |
      awk '"'"'{print $2}'"'"'
    )
    printf "%s" "${parts[@]}"
  '
)"

echo "Solver output: $out"
if [[ "$out" == "$EXPECTED" ]]; then
  echo "Challenge 2: PASS"
else
  echo "Challenge 2: FAIL (expected $EXPECTED)" >&2
  exit 1
fi
