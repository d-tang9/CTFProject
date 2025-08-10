#!/usr/bin/env bash
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="challenge3_bashrc_backdoor:latest"

mkdir -p "$HERE/app" "$HERE/app/profile.d"

# Flag content (change if you want)
cat > "$HERE/flag.txt" <<'FLAG'
FLAG{bashrc_backdoor_leaked_flag}
FLAG

# Backdoor payload that runs for login shells (via /etc/profile.d)
cat > "$HERE/app/profile.d/leak.sh" <<'PAYLOAD'
# Intentional vuln for the CTF challenge:
# On any login shell, copy root-only flag to a world-readable temp file.
( umask 022; cp /root/flag.txt /tmp/.cachefile 2>/dev/null || true; chmod 0644 /tmp/.cachefile 2>/dev/null || true )
PAYLOAD

# Also keep a .bashrc for teaching value (not strictly required now)
cat > "$HERE/app/.bashrc" <<'BRC'
alias ll='ls -alF'
# Marker so solvers can see .bashrc did load if they open an interactive shell
echo "[INFO] ctfuser .bashrc loaded" >/dev/null
BRC

# Entrypoint: start a login shell so /etc/profile.d/* runs for sure
cat > "$HERE/entrypoint.sh" <<'ENTRY'
#!/usr/bin/env bash
set -e
# Start a login shell; this sources /etc/profile -> /etc/profile.d/*.sh
exec bash -lc "sleep infinity"
ENTRY
chmod +x "$HERE/entrypoint.sh"

# Dockerfile
cat > "$HERE/Dockerfile" <<'DOCKER'
FROM ubuntu:22.04

# Create non-root user
RUN useradd -m -s /bin/bash ctfuser

# Place flag with strict perms
COPY flag.txt /root/flag.txt
RUN chmod 600 /root/flag.txt

# Install minimal tools
RUN apt-get update && apt-get install -y --no-install-recommends bash coreutils \
 && rm -rf /var/lib/apt/lists/*

# Install the backdoor payload for login shells
COPY app/profile.d/leak.sh /etc/profile.d/leak.sh
RUN chmod 0644 /etc/profile.d/leak.sh

# Optional: .bashrc for ctfuser (not relied on for the leak anymore)
COPY app/.bashrc /home/ctfuser/.bashrc
RUN chown ctfuser:ctfuser /home/ctfuser/.bashrc

# "Disable" root login inside the container:
# - Set root's shell to /usr/sbin/nologin
# - Lock root's password
# (Note: if someone can run the container with `--user 0`, they'll still be UID 0.
# In your CTF platform, block overriding the user.)
RUN chsh -s /usr/sbin/nologin root && passwd -l root || true

# Default to ctfuser
USER ctfuser
WORKDIR /home/ctfuser

# Start a login shell so the payload triggers at container start
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
DOCKER

echo "[*] Building $IMAGE_NAME ..."
docker build -t "$IMAGE_NAME" "$HERE"
echo "[+] Build complete."
echo "Run: ./challenge3/solve.sh"
