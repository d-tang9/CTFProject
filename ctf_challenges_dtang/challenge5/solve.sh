#!/usr/bin/env bash
set -euo pipefail

CONTAINER="challenge5"

# Ensure container exists
if ! docker ps -a --format '{{.Names}}' | grep -qx "$CONTAINER"; then
  echo "Container $CONTAINER not found. Run ./build.sh first." >&2
  exit 1
fi

# Non-interactive validation using less-as-cat behavior when stdout is not a TTY.
# We purposely do NOT allocate a TTY so less writes the file contents to stdout.
FLAG_OUT="$(docker exec "$CONTAINER" sudo -n /usr/bin/less /root/flag.txt)"

# Basic sanity check: print only the line containing the flag
if echo "$FLAG_OUT" | grep -E -q 'flag\{[[:alnum:]_@.-]+\}'; then
  echo "$FLAG_OUT" | grep -E 'flag\{[[:alnum:]_@.-]+\}'
else
  echo "Flag not found. Did the container build correctly?" >&2
  exit 2
fi
