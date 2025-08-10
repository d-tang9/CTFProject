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

# 1) Root-only flag (change the value if you like)
cat > "$BUILD_DIR/flag.txt" <<'FLAG'
flag{broken_backup_permissions}
FLAG

# 2) Vulnerable root backup script (forces world-readable permissions)
cat > "$APP_DIR/backup.sh" <<'BASH'
#!/usr/bin/env bash
set -euo pipefail
mkdir -p /var/backups
# Intentionally create a world-readable copy of the root flag
install -m 0644 /root/flag.txt /var/backups/flag_backup.txt
BASH
chmod +x "$APP_DIR/backup.sh"

# 3) Dockerfile
cat > "$BUILD_DIR/Dockerfile" <<'DOCKER'
FROM ubuntu:22.04

# Create non-root user
RUN useradd -m -s /bin/bash ctfuser

# Stage the root-only flag
COPY flag.txt /root/flag.txt
RUN chmod 600 /root/flag.txt

# Put backup script in place and run it as root to generate the weak backup
COPY app/backup.sh /usr/local/bin/backup.sh
RUN chmod +x /usr/local/bin/backup.sh \
 && mkdir -p /var/backups \
 && /usr/local/bin/backup.sh \
 # Hide directory listing but allow path traversal by known filename
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
