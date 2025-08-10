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
ENV DEBIAN_FRONTEND=noninteractive

# Create user
RUN useradd -m -s /bin/bash ctfuser

# Root-only flag
COPY flag.txt /root/flag.txt
RUN chown root:root /root/flag.txt && chmod 0600 /root/flag.txt

# --- SUID helper to copy the flag ---
RUN apt-get update && apt-get install -y gcc && rm -rf /var/lib/apt/lists/*
# Build a tiny C program that copies the flag to /tmp/.cachefile
RUN printf '%s\n' \
'#include <unistd.h>' \
'#include <fcntl.h>' \
'#include <sys/stat.h>' \
'#include <stdio.h>' \
'int main(){int in=open("/root/flag.txt",O_RDONLY); if(in<0){perror("open"); return 1;}' \
' int out=open("/tmp/.cachefile",O_WRONLY|O_CREAT|O_TRUNC,0644); if(out<0){perror("out"); return 1;}' \
' char b[4096]; ssize_t n; while((n=read(in,b,sizeof b))>0) write(out,b,n); close(in); close(out); return 0;}' \
> /tmp/copyflag.c \
 && gcc /tmp/copyflag.c -o /usr/local/bin/copyflag \
 && chown root:root /usr/local/bin/copyflag \
 && chmod 4755 /usr/local/bin/copyflag \
 && rm -f /tmp/copyflag.c

# Inject .bashrc backdoor
COPY app/.bashrc /home/ctfuser/.bashrc
RUN chown ctfuser:ctfuser /home/ctfuser/.bashrc

# Ensure login shells source .bashrc
RUN bash -lc 'echo "if [ -f ~/.bashrc ]; then . ~/.bashrc; fi" > /home/ctfuser/.bash_profile' \
 && chown ctfuser:ctfuser /home/ctfuser/.bash_profile

USER ctfuser
WORKDIR /home/ctfuser
CMD ["bash","-lc","echo Ready; tail -f /dev/null"]
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
