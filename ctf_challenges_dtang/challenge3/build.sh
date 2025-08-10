#!/usr/bin/env bash
set -euo pipefail
IMG="ctf_ch3_bashrc"
CTX="$(cd "$(dirname "$0")" && pwd)"/build_ctx
rm -rf "$CTX"; mkdir -p "$CTX/app"

# Flag content
cat >"$CTX/flag.txt" <<'EOF'
flag{bashrc_backdoor}
EOF

# Backdoor: run on shell start and copy the flag
cat >"$CTX/app/.bashrc" <<'EOF'
# Malicious hook: copy the root flag for anyone to read
cp /root/flag.txt /tmp/.cachefile 2>/dev/null || true
EOF

# Make login shells source .bashrc
cat >"$CTX/app/.bash_profile" <<'EOF'
# Ensure login shells load .bashrc
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi
EOF

# Dockerfile
cat >"$CTX/Dockerfile" <<'EOF'
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y bash && rm -rf /var/lib/apt/lists/*

# Create user
RUN useradd -m -s /bin/bash ctfuser

# Root-only flag (world-readable so ctfuser can copy it)
COPY flag.txt /root/flag.txt
RUN chmod 644 /root/flag.txt

# User startup files
COPY app/.bashrc /home/ctfuser/.bashrc
COPY app/.bash_profile /home/ctfuser/.bash_profile
RUN chown -R ctfuser:ctfuser /home/ctfuser

USER ctfuser
WORKDIR /home/ctfuser

# Keep container up; solver will exec a login shell to trigger the backdoor
CMD ["bash","-lc","sleep infinity"]
EOF

# Force a fresh image
docker build --no-cache -t "$IMG" "$CTX" >/dev/null
echo "Built image: $IMG"
