#!/usr/bin/env bash
set -euo pipefail

IMAGE="ctf-fragmented-flag:latest"
CTX="$(cd "$(dirname "$0")" && pwd)"/build_ctx

# Fresh context
rm -rf "$CTX"
mkdir -p "$CTX/homefiles"

# Create 50 text files in the user's home dir
for i in $(seq -w 1 50); do
  echo "nothing to see here $i" > "$CTX/homefiles/file${i}.txt"
done

# Flag split across 10 fragments
flag="fbujm38@db"
idx=1
for f in 05 10 15 20 25 30 35 40 45 50; do
  ch="${flag:idx-1:1}"
  echo "{fragment${idx}:${ch}}" >> "$CTX/homefiles/file${f}.txt"
  idx=$((idx+1))
done

# Breadcrumb in home
cat > "$CTX/homefiles/README.txt" <<'NOTE'
[ Challenge 2 ]
Your home folder has many .txt files.
Some lines look like {fragmentN:X}.
Sort N from 1..10 and join the X characters to get the flag.

Try:
  grep -R "{fragment" .
  # or one-liner:
  awk '{ if (match($0, /\{fragment([0-9]+):([^}]+)\}/, m)) print m[1], m[2] }' *.txt | sort -n | awk '{print $2}' | tr -d "\n"
NOTE

# Dockerfile: Alpine + Bash; copy files into /home/ctfuser
cat > "$CTX/Dockerfile" <<'EOF'
FROM alpine:3.20
RUN apk add --no-cache bash coreutils grep findutils
RUN adduser -D -s /bin/bash ctfuser
WORKDIR /home/ctfuser
COPY homefiles/ /home/ctfuser/
RUN chown -R ctfuser:ctfuser /home/ctfuser && chmod 444 /home/ctfuser/*.txt
USER ctfuser
# CMD ["bash"]
CMD ["sleep","infinity"]
EOF

docker build -t "$IMAGE" "$CTX" >/dev/null
echo "Built image: $IMAGE"
