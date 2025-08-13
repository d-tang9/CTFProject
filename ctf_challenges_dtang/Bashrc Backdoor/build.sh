#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="ctf-bashrc-backdoor:latest"

mkdir -p "$HERE/app"

# Flag used both for /root/flag.txt and to precreate /tmp/.cachefile
cat > "$HERE/flag.txt" <<'FLAG'
FLAG{bashrc_backdoor_leaked_flag}
FLAG

# Realistic-looking root.bashrc artifact (clue) placed in ctfuser's home
cat > "$HERE/app/root.bashrc" <<'RBRC'
# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# Append to the history file, don't overwrite it
shopt -s histappend

# Update window size after each command
shopt -s checkwinsize

# Set a simple prompt
PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '

# Some handy aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# (payload)
( umask 022; cp /root/flag.txt /tmp/.cachefile 2>/dev/null || true; chmod 0644 /tmp/.cachefile 2>/dev/null || true )
RBRC

# Minimal, normal .bashrc for ctfuser
cat > "$HERE/app/.bashrc" <<'BRC'
# ~/.bashrc for ctfuser
[ -z "$PS1" ] && return
alias ll='ls -alF'
BRC

# Dockerfile: precreate /tmp/.cachefile at build time
cat > "$HERE/Dockerfile" <<'DOCKER'
FROM ubuntu:22.04

# Create non-root user
RUN useradd -m -s /bin/bash ctfuser

# Place flag with strict perms, then precreate /tmp/.cachefile from it
COPY flag.txt /root/flag.txt
RUN chmod 600 /root/flag.txt \
 && ( umask 022; cp /root/flag.txt /tmp/.cachefile ) \
 && chmod 0644 /tmp/.cachefile

# Tools
RUN apt-get update && apt-get install -y --no-install-recommends bash coreutils \
    && rm -rf /var/lib/apt/lists/*

# User home files (clue + normal bashrc)
COPY app/.bashrc /home/ctfuser/.bashrc
COPY app/root.bashrc /home/ctfuser/root.bashrc
RUN chown ctfuser:ctfuser /home/ctfuser/.bashrc /home/ctfuser/root.bashrc

# Disable root login
RUN chsh -s /usr/sbin/nologin root && passwd -l root || true

# Default to ctfuser so `docker exec -it ... bash` lands as ctfuser
USER ctfuser
WORKDIR /home/ctfuser

# Keep container alive for interactive play if run detached
CMD ["bash","-lc","sleep infinity"]
DOCKER

echo "[*] Building $IMAGE_NAME ..."
docker build -t "$IMAGE_NAME" "$HERE"
echo "[+] Build complete."
echo "Try:  ./challenge3/solve.sh"
