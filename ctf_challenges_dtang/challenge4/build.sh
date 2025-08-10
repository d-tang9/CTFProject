#!/usr/bin/env bash
set -euo pipefail

# Config
IMAGE_NAME="challenge4"
TAG="latest"
BUILD_DIR="$(pwd)/challenge4"
APP_DIR="$BUILD_DIR/app"

# Fresh build context
rm -rf "$BUILD_DIR"
mkdir -p "$APP_DIR"

# ----- Challenge payloads -----

# 1) Root-only flag (you can change this value)
cat > "$BUILD_DIR/flag.txt" <<'FLAG'
flag{broken_backup_permissions}
FLAG

# 2) Vulnerable root backup script
cat > "$APP_DIR/backup.sh" <<'BASH'
#!/usr/bin/env bash
set -euo pipefail
# Intentionally unsafe: forces newly created files to be world-readable.
mkdir -p /var/backups
umask 000
cp /root/flag.txt /var/backups/flag_backup.txt
BASH
chmod +x "$APP_DIR/backup.sh"

# 3) Dockerfile
cat > "$BUILD_DIR/Dockerfile" <<'DOCKER'
FROM ubuntu:22.04

# Create non-root user early (uid/gid default ok)
RUN useradd -m -s /bin/bash ctfuser

# Stage the root-only flag
COPY flag.txt /root/flag.txt
RUN chmod 600 /root/flag.txt

# Put backup script in place
COPY app/backup.sh /usr/local/bin/backup.sh
RUN chmod +x /usr/local/bin/backup.sh

# Create backups dir, run backup as root with permissive umask (inside script)
# Then make the directory "traversable but not listable" for non-owners.
# 711 allows path traversal if you know the filename, but you can't list the dir.
RUN mkdir -p /var/backups \
 && /usr/local/bin/backup.sh \
 && chmod 711 /var/backups

# Drop to non-root for players
USER ctfuser
WORKDIR /home/ctfuser
CMD ["/bin/bash","-l"]
DOCKER

# ----- Build image -----
docker build -t "${IMAGE_NAME}:${TAG}" "$BUILD_DIR"

echo
echo "Built ${IMAGE_NAME}:${TAG}"
