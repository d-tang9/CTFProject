#!/usr/bin/env bash
set -euo pipefail
IMG="ctf_ch10_suid"
CTX="$(cd "$(dirname "$0")" && pwd)"/build_ctx
rm -rf "$CTX"; mkdir -p "$CTX/app"

cat >"$CTX/flag.txt" <<'EOF'
flag{path_hijack_suid}
EOF

cat >"$CTX/app/vuln.c" <<'EOF'
#include <stdlib.h>
int main(){ system("logger"); return 0; }
EOF

cat >"$CTX/Dockerfile" <<'EOF'
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y build-essential bash && rm -rf /var/lib/apt/lists/*
RUN useradd -m -s /bin/bash ctfuser
WORKDIR /home/ctfuser
COPY app/vuln.c ./vuln.c
RUN gcc vuln.c -o vuln && chown root:root vuln && chmod 4755 vuln
COPY flag.txt /root/flag.txt
RUN chmod 600 /root/flag.txt
USER ctfuser
CMD ["bash"]
EOF

docker build -t "$IMG" "$CTX" >/dev/null
echo "Built image: $IMG"
