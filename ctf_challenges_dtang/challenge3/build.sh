#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="challenge3_bashrc_backdoor:latest"

mkdir -p "$HERE/app"

# Flag
cat > "$HERE/flag.txt" <<'FLAG'
FLAG{bashrc_backdoor_leaked_flag}
FLAG

# Entry point runs ONCE as root to leak the flag, then drops to ctfuser
cat > "$HERE/entrypoint.sh" <<'ENTRY'
#!/usr/bin/env bash
set -euo pipefail

# 1) Leak as root (has read access to /root/flag.txt)
( umask 022; cp /root/flag.txt /tmp/.cachefile; chmod 0644 /tmp/.cachefile )

# 2) Drop to ctfuser and keep a login shell alive (so /etc/profile etc. still run)
exec su -s /bin/bash -l ctfuser -c 'bash -lc "sleep infinity"'
ENTRY
chmod +x "$HERE/entrypoint.sh"

# Optional .bashrc (teaching marker)
cat > "$HERE/app/.bashrc" <<'BRC'
alias ll='ls -alF'
BRC

# Dockerfile
cat > "$HERE/Dockerfile" <<'DOCKER'
FROM ubuntu:22.04

# Create non-root user
RUN useradd -m -s /bin/bash ctfuser

# Flag with strict perms
COPY flag.txt /root/flag.txt
RUN chmod 600 /root/flag.txt

# Tools
RUN apt-get update && apt-get install -y --no-install-recommends bash coreutils \
    && rm -rf /var/lib/apt/lists/*

# Teaching marker
COPY app/.bashrc /home/ctfuser/.bashrc
RUN chown ctfuser:ctfuser /home/ctfuser/.bashrc

# Disable root *login* (but entrypoint still runs as PID 1 with root privileges)
RUN chsh -s /usr/sbin/nologin root && passwd -l root || true

# Start as root so we can perform the one-time leak, then drop to ctfuser
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
DOCKER

echo "[*] Building $IMAGE_NAME ..."
docker build -t "$IMAGE_NAME" "$HERE"
echo "[+] Build complete."
