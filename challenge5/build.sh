#!/usr/bin/env bash
set -euo pipefail
IMG="ctf_ch5_sudo_less"
CTX="$(cd "$(dirname "$0")" && pwd)"/build_ctx
rm -rf "$CTX"; mkdir -p "$CTX/app"

cat >"$CTX/flag.txt" <<'EOF'
flag{sudo_less_shell}
EOF

cat >"$CTX/app/sudoers_ctfuser" <<'EOF'
ctfuser ALL=(ALL) NOPASSWD: /usr/bin/less
EOF

cat >"$CTX/Dockerfile" <<'EOF'
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y sudo less && rm -rf /var/lib/apt/lists/*
RUN useradd -m -s /bin/bash ctfuser
COPY flag.txt /root/flag.txt
RUN chmod 600 /root/flag.txt
COPY app/sudoers_ctfuser /etc/sudoers.d/ctfuser
RUN chmod 0440 /etc/sudoers.d/ctfuser
USER ctfuser
WORKDIR /home/ctfuser
CMD ["bash"]
EOF

docker build -t "$IMG" "$CTX" >/dev/null
echo "Built image: $IMG"
