#!/usr/bin/env bash
set -euo pipefail
IMG="ctf_ch1_zip"
CTX="$(cd "$(dirname "$0")" && pwd)"/build_ctx
rm -rf "$CTX"; mkdir -p "$CTX"

cat >"$CTX/flag.txt" <<'EOF'
flag{bruteforce_zip}
EOF

cat >"$CTX/wordlist.txt" <<'EOF'
password
123456
qwerty
letmein
lol123
secret
winter2025
dragon
EOF

(cd "$CTX" && zip --password lol123 secret.zip flag.txt >/dev/null)
rm -f "$CTX/flag.txt"

cat >"$CTX/Dockerfile" <<'EOF'
FROM python:3.11-slim
RUN useradd -m -s /bin/bash ctfuser
WORKDIR /home/ctfuser
COPY secret.zip wordlist.txt ./
RUN chown -R ctfuser:ctfuser /home/ctfuser
USER ctfuser
CMD ["bash"]
EOF

docker build -t "$IMG" "$CTX" >/dev/null
echo "Built image: $IMG"
