#!/usr/bin/env bash
set -euo pipefail

IMAGE="challenge9:latest"
CONTAINER="challenge9"

have_image() { docker image inspect "$IMAGE" >/dev/null 2>&1; }
have_container() { docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER}$"; }

# -------- Stage build context (same as before) --------

# Fresh workspace
rm -rf app
mkdir -p app

# Flag (root-only)
cat > app/flag.txt <<'FLAG'
flag{cron_cleanup_got_pwned}
FLAG

# Root cron-executed cleanup script (intentionally unsafe)
cat > app/cleanup.sh <<'CLEAN'
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
CLEAN
chmod +x app/cleanup.sh

# Breadcrumbs for players
cat > app/NOTICE.txt <<'NOTE'
[ System Maintenance Notice ]
A root cron task runs /usr/local/bin/cleanup.sh every minute to process scripts
dropped into /var/cleanup/. If you put an executable there, it should get picked
up automatically. Logs: /var/log/cleanup.log
NOTE

# Dockerfile (Alpine + bash + busybox crond)
cat > app/Dockerfile <<'DOCKER'
FROM alpine:3.20

# Need bash for scripts. (Busybox provides crond.)
RUN apk add --no-cache bash

# Create non-root player and workspace
RUN adduser -D -s /bin/bash ctfuser

# Flag (root only)
COPY flag.txt /root/flag.txt
RUN chmod 600 /root/flag.txt

# Vulnerable cleanup + breadcrumbs
COPY cleanup.sh /usr/local/bin/cleanup.sh
RUN chmod 755 /usr/local/bin/cleanup.sh
RUN mkdir -p /var/cleanup /var/log && chmod 0777 /var/cleanup

# Breadcrumb for players
COPY NOTICE.txt /home/ctfuser/NOTICE.txt
RUN chown -R ctfuser:ctfuser /home/ctfuser

# Root crontab (Alpine style)
# Runs every minute, logs to /var/log/cleanup.log
RUN echo '* * * * * /bin/bash /usr/local/bin/cleanup.sh >> /var/log/cleanup.log 2>&1' > /etc/crontabs/root

# Keep cron running (use the correct spool dir) and keep the container alive
CMD ["/bin/bash","-lc","/usr/sbin/crond -l 8 -c /etc/crontabs; tail -f /dev/null"]
DOCKER

# -------- Build (idempotent) --------

if ! have_image || [[ "${1:-}" == "--rebuild" ]]; then
  echo "[i] Building $IMAGE from ./app ..."
  docker build -t "$IMAGE" app
else
  echo "[i] Image $IMAGE already exists. Skipping build. Use --rebuild to force."
fi

# -------- Run detached (idempotent) --------

if have_container; then
  echo "[i] Removing existing container..."
  docker rm -f "$CONTAINER" >/dev/null
fi

echo "[i] Starting container detached..."
docker run -d --name "$CONTAINER" "$IMAGE" \
  /bin/bash -lc "/usr/sbin/crond -l 8 -c /etc/crontabs; tail -f /dev/null"

echo "[i] Container status:"
docker ps --filter "name=$CONTAINER"

echo
echo "[i] Ready."
echo "    - Validate:      ./solve.sh"
echo "    - Manual play:   docker exec -it $CONTAINER bash"
echo "    - View logs:     docker logs -f $CONTAINER"
