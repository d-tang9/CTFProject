#!/bin/bash
set -euo pipefail

CHAL_NAME="challenge7"

# Create a fake 'date' that returns the unlock time and place it ahead in PATH
# Breadcrumbs put $HOME/bin first via .bashrc, so we can just drop it there.
FAKE_DATE='#!/bin/bash
if [[ "$1" == "+%H:%M" ]]; then
  echo "04:00"
else
  /bin/date "$@"
fi
'
docker exec -u ctfuser "${CHAL_NAME}" bash -lc "printf '%s\n' '${FAKE_DATE}' > ~/bin/date && chmod +x ~/bin/date"

# Run the checker; it should pass integrity and the faked time, then print the flag
docker exec -u ctfuser "${CHAL_NAME}" bash -lc "/opt/check_flag.sh"
