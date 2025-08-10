#!/usr/bin/env bash
set -euo pipefail

IMAGE="challenge2-fragments:latest"
CTX="$(cd "$(dirname "$0")" && pwd)"/build_ctx

# Fresh context
rm -rf "$CTX"
mkdir -p "$CTX/data"

# Decoy files
for i in $(seq -w 1 50); do
  echo "nothing to see here $i" > "$CTX/data/file${i}.txt"
done

# Flag split across 10 fragments
flag="fbujm38@db"
idx=1
for f in 05 10 15 20 25 30 35 40 45 50; do
  ch="${flag:idx-1:1}"
  echo "{fragment${idx}:${ch}}" >> "$CTX/data/file${f}.txt"
  idx=$((idx+1))
done

# Breadcrumb for players (subtle but enough)
cat > "$CTX/README.txt" <<'NOTE'
[ Challenge 2 ]
Fifty text files live under /opt/data.
Some lines look like {fragmentN:X}. Put N=1..10 in order to build the 10-character flag.

Hints:
- Try: grep -R "{fragment" /opt/data
- Sort by N, then print the character X
NOTE

# Alpine + Bash, lightweight
cat > "$CTX/Dockerfile" <<'EOF'
FROM alpine:3.20
RUN apk add --no-cache bash coreutils grep sed
RUN adduser -D -s /bin/bash ctfuser
WORKDIR /home/ctfuser
COPY data /opt/data
COPY README.txt /home/ctfuser/README.txt
RUN chmod 444 /opt/data/* && chown -R ctfuser:ctfuser /opt /home/ctfuser
USER ctfuser
CMD ["bash"]
EOF

docker build -t "$IMAGE" "$CTX" >/dev/null
echo "Built image: $IMAGE"
