#!/usr/bin/env bash
set -euo pipefail

IMAGE="${IMAGE:-challenge2-fragments:latest}"
NAME="${NAME:-challenge2-fragments}"
EXPECTED="fbujm38@db"
HOME_DIR="/home/ctfuser"
RESET="${RESET:-0}"   # set RESET=1 to recreate the container

require() { command -v "$1" >/dev/null || { echo "Missing $1" >&2; exit 1; }; }
image_exists() { docker image inspect "$1" >/dev/null 2>&1; }
container_exists() { docker ps -a --format '{{.Names}}' | grep -Fxq "$1"; }
container_running() { docker ps --format '{{.Names}}' | grep -Fxq "$1"; }

exec_in() {
  if docker exec "$NAME" bash -lc 'true' >/dev/null 2>&1; then
    docker exec "$NAME" bash -lc "$1"
  else
    docker exec "$NAME" sh -lc "$1"
  fi
}

require docker

echo "[*] Ensuring image present: $IMAGE"
if ! image_exists "$IMAGE"; then
  [[ -f ./build.sh ]] || { echo "Image $IMAGE not present and build.sh missing." >&2; exit 1; }
  echo "[*] Building image..."
  bash ./build.sh
fi

# Recreate container if requested
if [[ "$RESET" == "1" ]] && container_exists "$NAME"; then
  echo "[*] RESET=1 -> removing existing container: $NAME"
  docker rm -f "$NAME" >/dev/null || true
fi

if ! container_exists "$NAME"; then
  echo "[*] Creating container: $NAME"
  docker create --name "$NAME" -w "$HOME_DIR" "$IMAGE" >/dev/null
fi
if ! container_running "$NAME"; then
  echo "[*] Starting container: $NAME"
  docker start "$NAME" >/dev/null
fi

# --- run solver with debug output ---
out_and_debug="$(exec_in "
  set -euo pipefail
  cd '$HOME_DIR' || { echo '[debug] cannot cd to $HOME_DIR' >&2; exit 2; }

  echo '[debug] whoami=' \$(whoami) >&2
  echo '[debug] pwd=' \$(pwd) >&2
  echo '[debug] ls sample:' >&2
  ls -la | head -n 10 >&2

  # Show how many fragment-like lines exist
  matches=\$(grep -Rho -E '[{]fragment[0-9]+:[^}]+' . 2>/dev/null | wc -l || true)
  echo '[debug] matches found:' \${matches} >&2

  # Parse WITHOUT regex captures:
  # 1) grep fragment lines
  # 2) split on any of { } : using -F'[{}:]'
  #    fields: $2='fragmentN', $3='X'
  # 3) strip 'fragment' prefix to get N
  # 4) print 'N X', sort numerically, then join X chars
  grep -Rho -E '[{]fragment[0-9]+:[^}]+' . 2>/dev/null |
    awk -F'[{}:]' '{
      n=\$2; sub(/^fragment/, \"\", n);
      print n, \$3
    }' |
    sort -n |
    awk '{printf \"%s\", \$2}'
")"

# Separate debug (stderr) from actual output (last line printed to stdout)
# docker exec interleaves; we only need the last line for value comparison.
out="$(printf "%s" "$out_and_debug" | tail -n 1)"

echo "Solver output: $out"
if [[ "$out" == "$EXPECTED" ]]; then
  echo "Challenge 2: PASS"
else
  echo "Challenge 2: FAIL (expected $EXPECTED)" >&2
  echo
  echo "If this is a stale container, run: RESET=1 ./solve.sh"
  exit 1
fi
