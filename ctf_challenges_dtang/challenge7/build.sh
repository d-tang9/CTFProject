#!/usr/bin/env bash
set -euo pipefail
IMG="ctf_ch7_time"
CTX="$(cd "$(dirname "$0")" && pwd)"/build_ctx
rm -rf "$CTX"; mkdir -p "$CTX"

# Step 1: Write script without checksum
cat >"$CTX/check_flag.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
expected="__PLACEHOLDER_SHA__"
actual="$(sha256sum "$0" | cut -d' ' -f1)"
if [[ "$expected" != "$actual" ]]; then
  echo "Tampering detected"
  exit 1
fi
t="$(date +%H:%M)"
if [[ "$t" == "04:00" ]]; then
  cat flag.txt
else
  echo "Not time yet"
  exit 2
fi
EOF

# Step 2: Compute checksum and patch into script
sha=$(sha256sum "$CTX/check_flag.sh" | cut -d' ' -f1)
sed -i "s/__PLACEHOLDER_SHA__/$sha/" "$CTX/check_flag.sh"

chmod +x "$CTX/check_flag.sh"

# Step 3: Write flag
cat >"$CTX/flag.txt" <<'EOF'
flag{time_unlock_0400}
EOF

# Step 4: Dockerfile
cat >"$CTX/Dockerfile" <<'EOF'
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y coreutils bash && rm -rf /var/lib/apt/lists/*
RUN useradd -m -s /bin/bash ctfuser
WORKDIR /home/ctfuser
COPY check_flag.sh flag.txt ./
RUN chown -R ctfuser:ctfuser /home/ctfuser && chmod 600 flag.txt && chmod 555 check_flag.sh
USER ctfuser
CMD ["bash"]
EOF

# Step 5: Build image
docker build -t "$IMG" "$CTX" >/dev/null
echo "Built image: $IMG"
