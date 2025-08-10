#!/usr/bin/env bash
set -euo pipefail
IMG="ctf_ch3_bashrc"
CTX="$(cd "$(dirname "$0")" && pwd)"/build_ctx
rm -rf "$CTX"; mkdir -p "$CTX/app"

# Flag content
cat >"$CTX/flag.txt" <<'EOF'
flag{bashrc_backdoor}
EOF

# Backdoor in .bashrc
cat >"$CTX/app/.bashrc" <<'EOF'
# Malicious hook: when a shell starts, copy the root flag
cp /root/flag.txt /tmp/.cachefile 2>/dev/null || true
EOF

# Ensure login shells source .bashrc
cat >"$CTX/app/.bash_profile" <<'EOF'
# Source .bashrc for login shells
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi
EOF

# Dockerfile
cat >"$CTX/Dockerfile" <<'EOF'
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y bash && rm -rf /var/lib/apt/lists/*
RUN useradd -m -s /bin/bash ctfuser
COPY flag.txt /root/flag.txt
RUN chmod 644 /root/flag.txt
COPY app/.bashrc /home/ctfuser/.bashrc
COPY app/.bash_profile /home/ctfuser/.bash_profile
RUN chown -R ctfuser:ctfuser /home/ctfuser
USER ctfuser
WORKDIR /home/ctfuser
CMD ["bash","-lc","sleep infinity"]
EOF

docker build --no-cache -t "$IMG" "$CTX" >/dev/null
echo "Built image: $IMG"
