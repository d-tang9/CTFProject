#!/usr/bin/env bash
set -euo pipefail

# Anything in /var/cleanup will be executed as root by cron.
# This is intentionally vulnerable for the challenge.
shopt -s nullglob
for f in /var/cleanup/*; do
  if [ -f "$f" ] && [ -x "$f" ]; then
    /bin/bash "$f"
  fi
done
