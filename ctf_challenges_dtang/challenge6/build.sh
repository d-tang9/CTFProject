#!/usr/bin/env bash
set -euo pipefail
IMG="ctf_ch6_hidden"
CTX="$(cd "$(dirname "$0")" && pwd)"/build_ctx
rm -rf "$CTX"; mkdir -p "$CTX/app"

dd if=/dev/urandom of="$CTX/app/random.bin" bs=1K count=1 >/dev/null 2>&1
printf '{flag_hidden_here}' | dd of="$CTX/app/random.bin" bs=1 seek=500 conv=notrunc >/dev/null 2>&1

name_hex="$(echo -n 'note_flag.txt' | xxd -p -u)"
mv "$CTX/app/random.bin" "$CTX/app/$name_hex"

cat >"$CTX/Dockerfile" <<'EOF'
\1RUN apk add --no-cache binutils
RUN adduser -D -s /bin/sh ctfuser
WORKDIR /home/ctfuser
COPY app/ ./
USER ctfuser
CMD ["sh"]
EOF

docker build -t "$IMG" "$CTX" >/dev/null
echo "Built image: $IMG"
