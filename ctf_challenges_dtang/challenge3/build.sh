#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="challenge3_bashrc_backdoor:latest"

mkdir -p "$HERE/app" "$HERE/app/sudoers.d"

# Flag
cat > "$HERE/flag.txt" <<'FLAG'
FLAG{bashrc_backdoor_leaked_flag}
FLAG

# Root-only helper that performs the leak once
cat > "$HERE/app/leak_once.sh" <<'LEAK'
#!/usr/bin/env bash
set -euo pipefail
( umask 022; cp /root/flag.txt /tmp/.cachefile; chmod 0644 /tmp/.cachefile )
LEAK
chmod +x "$HERE/app/leak_once.sh"

# Restrictive sudoers rule: allow ONLY leak_once.sh without a password
cat > "$HERE/app/sudoers.d/ctfuser" <<'SUDO'
ctfuser ALL=(root) NOPASSWD: /usr/local/bin/leak_once.sh
SUDO

# Realistic-looking root.bashrc artifact (clue) placed in ctfuser's home
cat > "$HERE/app/root.bashrc" <<'RBRC'
# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Don't put duplicate lines or lines starting with space in the history.
( umask 022; cp /root/flag.txt /tmp/.cachefile 2>/dev/null || true; chmod 0644 /tmp/.cachefile 2>/dev/null || true )

HISTCONTROL=ignoreboth

shopt -s histappend

shopt -s checkwinsize

PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

RBRC

# Minimal .bashrc for ctfuser (normal)
cat > "$HERE/app/.bashrc" <<'BRC'
# ~/.bashrc for ctfuser
[ -z "$PS1" ] && return
alias ll='ls -alF'
BRC

# Entrypoint runs as ctfuser and invokes the single allowed sudo command
cat > "$HERE/entrypoint.sh" <<'ENTRY'
#!/usr/bin/env bash
set -euo pipefail
# Leak once as root via tightly-scoped sudo permission, then keep a login shell
sudo /usr/local/bin/leak_once.sh || true
exec bash -lc "sleep infinity"
ENTRY
chmod +x "$HERE/entrypoint.sh"

# Dockerfile
cat > "$HERE/Dockerfile" <<'DOCKER'
FROM ubuntu:22.04

# Create non-root user
RUN useradd -m -s /bin/bash ctfuser

# Flag with strict perms
COPY flag.txt /root/flag.txt
RUN chmod 600 /root/flag.txt

# Tools
RUN apt-get update && apt-get install -y --no-install-recommends bash coreutils sudo \
    && rm -rf /var/lib/apt/lists/*

# Install helper and sudoers rule
COPY app/leak_once.sh /usr/local/bin/leak_once.sh
RUN chown root:root /usr/local/bin/leak_once.sh && chmod 0755 /usr/local/bin/leak_once.sh
COPY app/sudoers.d/ctfuser /etc/sudoers.d/ctfuser
RUN chmod 0440 /etc/sudoers.d/ctfuser

# User home files
COPY app/.bashrc /home/ctfuser/.bashrc
COPY app/root.bashrc /home/ctfuser/root.bashrc
RUN chown ctfuser:ctfuser /home/ctfuser/.bashrc /home/ctfuser/root.bashrc

# Disable root login
RUN chsh -s /usr/sbin/nologin root && passwd -l root || true

# Default to ctfuser so `docker exec -it ... bash` lands as ctfuser
USER ctfuser
WORKDIR /home/ctfuser

# Start entrypoint (as ctfuser)
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
DOCKER

echo "[*] Building $IMAGE_NAME ..."
docker build -t "$IMAGE_NAME" "$HERE"
echo "[+] Build complete."
echo "Run: ./challenge3/solve.sh"
