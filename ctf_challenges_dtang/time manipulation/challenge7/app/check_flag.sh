#!/bin/bash
set -euo pipefail

UNLOCK_HHMM="04:00"
SELF="/opt/check_flag.sh"
SIG="/opt/check_flag.sha256"
READER="/usr/local/bin/readflag"

if [[ ! -r "$SIG" ]]; then
  echo "Integrity signature missing. Aborting."
  exit 1
fi

self_sum="$(sha256sum "$SELF" | awk '{print $1}')"
expected_sum="$(tr -d '\r\n' < "$SIG")"
if [[ "$self_sum" != "$expected_sum" ]]; then
  echo "Tampering detected. Aborting."
  exit 1
fi

now="$(date +%H:%M)"
if [[ "$now" != "$UNLOCK_HHMM" ]]; then
  echo "Access denied: window locked (now=$now, need=$UNLOCK_HHMM)."
  exit 1
fi

exec "$READER"
