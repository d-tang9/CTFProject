#!/bin/bash
set -e

IMAGE="challenge3"
CONTAINER="challenge3"

echo "[*] Building Challenge 3..."

# Clean up old container/image
docker rm -f $CONTAINER >/dev/null 2>&1 || true
docker rmi $IMAGE >/dev/null 2>&1 || true

# Create temporary build context
TMPDIR=$(mktemp -d)
mkdir -p "$TMPDIR/app"

# Root-only flag
echo "flag{bashrc_backdoor_example}" > "$TMPDIR/flag.txt"

# .bashrc backdoor
cat > "$TMPDIR/app/.bashrc" <<'EOF'
# Hidden backdoor: copy root flag to a temp file
cp /root/flag.txt /tmp/.cachefile 2>/dev/null || true
EOF

# Dockerfile
cat > "$TMPDIR/Dockerfile" <<'EOF'
FROM ubuntu:20.04
RUN useradd -m ctfuser
COPY flag.txt /root/flag.txt
RUN chmod 600 /root/flag.txt
COPY app/.bashrc /home/ctfuser/.bashrc
RUN chown ctfuser:ctfuser /home/ctfuser/.bashrc
USER ctfuser
WORKDIR /home/ctfuser
CMD ["bash", "-l"]
EOF

# Build image
docker build -t $IMAGE "$TMPDIR"

# Start container
docker run -d --name $CONTAINER $IMAGE tail -f /dev/null

# Remove build context
rm -rf "$TMPDIR"

echo "[+] Challenge 3 container is running."
