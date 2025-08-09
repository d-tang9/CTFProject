#!/usr/bin/env bash
set -euo pipefail
IMG="ctf_ch7_time"
CTX="$(cd "$(dirname "$0")" && pwd)"/build_ctx
rm -rf "$CTX"; mkdir -p "$CTX"

cat >"$CTX/check_flag.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
expected="86a080ba7d3feee1ad6cca7491fbc867fe1c02e3dd819bb3a3d01a89c7fb69a1"
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
chmod +x "$CTX/check_flag.sh"

cat >"$CTX/flag.txt" <<'EOF'
flag{time_unlock_0400}
EOF

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

# inject the script
sed -i "s|#!/usr/bin/env bash
set -euo pipefail
expected="86a080ba7d3feee1ad6cca7491fbc867fe1c02e3dd819bb3a3d01a89c7fb69a1"
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
|$(sed 's|[\&/]|\\&|g' "$CTX/check_flag.sh")|" "$CTX/check_flag.sh" >/dev/null 2>&1 || true

docker build -t "$IMG" "$CTX" >/dev/null
echo "Built image: $IMG"
