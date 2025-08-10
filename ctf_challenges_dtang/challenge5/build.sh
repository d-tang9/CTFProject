#!/usr/bin/env bash
set -euo pipefail

# Challenge 5: Misconfigured Sudoers (less NOPASSWD)
# Image/tag and container names
IMAGE="ctf-challenge5:latest"
CONTAINER="challenge5"

# Clean any dangling previous container (best-effort)
if docker ps -a --format '{{.Names}}' | grep -qx "$CONTAINER"; then
  docker rm -f "$CONTAINER" >/dev/null 2>&1 || true
fi

# Create build context
mkdir -p app
cat > app/flag.txt <<'EOF'
flag{sudo_less_escape}
EOF

# Sudoers drop-in granting ctfuser NOPASSWD for /usr/bin/less only
cat > app/ctfuser_sudoers <<'EOF'
ctfuser ALL=(ALL) NOPASSWD: /usr/bin/less
EOF

# Dockerfile
cat > app/Dockerfile <<'EOF'
FROM ubuntu:22.04

# Minimal tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo less ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Add a non-root user
RUN useradd -m -s /bin/bash ctfuser

# Put the flag in /root with tight permissions
COPY flag.txt /root/flag.txt
RUN chown root:root /root/flag.txt && chmod 600 /root/flag.txt

# Configure sudoers: allow only /usr/bin/less without password
COPY ctfuser_sudoers /etc/sudoers.d/ctfuser
RUN chown root:root /etc/sudoers.d/ctfuser && chmod 0440 /etc/sudoers.d/ctfuser

# Default to ctfuser
USER ctfuser
WORKDIR /home/ctfuser

# Keep the container running so players have time to solve
CMD ["sleep", "infinity"]
EOF

# Build
docker build -t "$IMAGE" app

# Run fresh container
docker run -d --name "$CONTAINER" "$IMAGE" >/dev/null

echo "✅ Built and started $CONTAINER from $IMAGE"
#echo
#echo "Manual solve hint (for players):"
#echo "  docker exec -it $CONTAINER bash"
#echo "  ctfuser@container$ sudo /usr/bin/less /etc/hosts"
#echo "  Inside less type:  !/bin/sh    (then press Enter)"
#echo "  # cat /root/flag.txt"
