#!/bin/bash
set -euo pipefail

# Config
IMAGE_TAG="ctf-ch3:bashrc-backdoor"
CONTAINER_NAME="challenge3"
BUILD_DIR="$(dirname "$0")/.build"

echo "[*] Preparing build context at ${BUILD_DIR}..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Flag staged outside user home; root-readable only inside image
cat > "$BUILD_DIR/flag.txt" <<'EOF'
flag{bashrc_backdoor_demo}
EOF

# User's .bashrc with the backdoor copy
mkdir -p "$BUILD_DIR/app"
cat > "$BUILD_DIR/app/.bashrc" <<'EOF'
# --- benign prompt tweaks could be here ---
# Backdoor: copy root-only flag into a world-readable temp cache on login
cp /root/flag.txt /tmp/.cachefile 2>/dev/null || true
chmod 0644 /tmp/.cachefile 2>/dev/null || true
EOF

# Dockerfile
cat > "$BUILD_DIR/Dockerfile" <<'EOF'
FROM ubuntu:22.04

# Avoid tzdata prompts
ENV DEBIAN_FRONTEND=noninteractive

# Create non-root user
RUN useradd -m -s /bin/bash ctfuser

# Place the root-only flag
COPY flag.txt /root/flag.txt
RUN chown root:root /root/flag.txt && chmod 0600 /root/flag.txt

# Install bash (already present) and set up user's .bashrc
COPY app/.bashrc /home/ctfuser/.bashrc
RUN chown ctfuser:ctfuser /home/ctfuser/.bashrc

USER ctfuser
WORKDIR /home/ctfuser

# Keep container alive for interactive solving
CMD ["bash", "-lc", "echo 'Container ready. Use solve.sh to trigger the backdoor.'; tail -f /dev/null"]
EOF

echo "[*] Building image ${IMAGE_TAG}..."
docker build -t "$IMAGE_TAG" "$BUILD_DIR"

# Recreate container cleanly
if docker ps -a --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
  echo "[*] Removing existing container ${CONTAINER_NAME}..."
  docker rm -f "$CONTAINER_NAME" >/dev/null
fi

echo "[*] Starting container ${CONTAINER_NAME}..."
docker run -d --name "$CONTAINER_NAME" "$IMAGE_TAG" >/dev/null

echo "[+] Build complete. Container '${CONTAINER_NAME}' is running."
