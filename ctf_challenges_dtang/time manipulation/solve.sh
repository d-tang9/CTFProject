#!/bin/bash
set -euo pipefail

CHAL_NAME="challenge7"

# Ensure ~/bin exists even if shell configs didn’t run for some reason
docker exec -u ctfuser "${CHAL_NAME}" bash -lc 'mkdir -p "$HOME/bin"'

# Drop a fake date that reports the unlock time for +%H:%M
FAKE_DATE='#!/bin/bash
if [[ "$1" == "+%H:%M" ]]; then
  echo "04:00"
else
  /bin/date "$@"
fi
'
docker exec -u ctfuser "${CHAL_NAME}" bash -lc "printf '%s\n' '${FAKE_DATE}' > \"\$HOME/bin/date\" && chmod +x \"\$HOME/bin/date\""

# Run the checker; should now print the flag
docker exec -u ctfuser "${CHAL_NAME}" bash -lc "/opt/check_flag.sh"
