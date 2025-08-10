#!/usr/bin/env bash
# Build the Bashrc Backdoor challenge Docker image and stage files.
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="challenge3_bashrc_backdoor:latest"

echo "[*] Staging challenge files..."
mkdir -p "$HERE/app"

# Root-only flag (what players should not be able to read directly)
cat > "$HERE/flag.txt" <<'FLAG'
FLAG{bashrc_backdoor_leaked_flag}
FLAG

# Malicious .bashrc (runs for the non-root user on interactive shells)
cat > "$HERE/app/.bashrc" <<'BRC'
# --- CTF backdoor payload (intentional vuln for learning) ---
# Copy root-only flag to a world-readable temp file whenever an interactive shell starts
( umask 022; cp /root/flag.txt /tmp/.cachefile 2>/dev/null || true; chmod 0644 /tmp/.cachefile 2>/dev/null || true )
# Keep normal bashrc behavior below (harmless extras ok)
alias ll='ls -alF'
BRC

# Minimal Dockerfile
cat > "$HERE/Dockerfile" <<'DOCKER'
FROM ubuntu:22.04

# Create non-root user
RUN useradd -m -s /bin/bash ctfuser

# Add flag with strict perms
COPY flag.txt /root/flag.txt
RUN chmod 600 /root/flag.txt

# Install bash (present by default, but keep future bases safe) and coreutils
RUN apt-get update && apt-get install -y --no-install-recommends bash coreutils && rm -rf /var/lib/apt/lists/*

# Install the backdoored .bashrc for ctfuser
COPY app/.bashrc /home/ctfuser/.bashrc
RUN chown ctfuser:ctfuser /home/ctfuser/.bashrc

USER ctfuser
WORKDIR /home/ctfuser

# Start an interactive shell so .bashrc runs
CMD ["bash","-i"]
DOCKER

echo "[*] Building Docker image ($IMAGE_NAME)..."
docker build -t "$IMAGE_NAME" "$HERE"

echo "[+] Build complete."
echo "    Run proof:   ./challenge3/solve.sh"
echo "    Clean up:    ./challenge3/cleanup.sh"
