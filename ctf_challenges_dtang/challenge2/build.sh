#!/usr/bin/env bash
set -euo pipefail
IMG="challenge2"
CTX="$(cd "$(dirname "$0")" && pwd)"/build_ctx
rm -rf "$CTX"; mkdir -p "$CTX/data"

for i in $(seq -w 1 50); do echo "nothing to see here $i" >"$CTX/data/file${i}.txt"; done

flag="fbujm38@db"
idx=1
for f in 05 10 15 20 25 30 35 40 45 50; do
  ch="${flag:idx-1:1}"
  echo "{fragment${idx}:${ch}}" >>"$CTX/data/file${f}.txt"
  idx=$((idx+1))
done

cat >"$CTX/Dockerfile" <<'EOF'
FROM python:3.11-slim
RUN useradd -m -s /bin/bash ctfuser
WORKDIR /home/ctfuser
COPY data /data
RUN chmod 444 /data/* && chown -R ctfuser:ctfuser /data
USER ctfuser
CMD ["bash"]
EOF

docker build -t "$IMG" "$CTX" >/dev/null
echo "Built image: $IMG"
