#!/usr/bin/env bash
set -euo pipefail
IMG="ctf_ch4_backup"
CTX="$(cd "$(dirname "$0")" && pwd)"/build_ctx
rm -rf "$CTX"; mkdir -p "$CTX/app"

cat >"$CTX/flag.txt" <<'EOF'
flag{backup_perms_leak}
EOF

cat >"$CTX/app/backup.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
umask 000
mkdir -p /var/backups
cp /root/flag.txt /var/backups/flag_backup.txt
chmod 711 /var/backups || true
EOF
chmod +x "$CTX/app/backup.sh"

cat >"$CTX/Dockerfile" <<'EOF'
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y bash coreutils && rm -rf /var/lib/apt/lists/*
COPY flag.txt /root/flag.txt
RUN chmod 600 /root/flag.txt
COPY app/backup.sh /usr/local/bin/backup.sh
RUN bash /usr/local/bin/backup.sh
RUN useradd -m -s /bin/bash ctfuser
USER ctfuser
WORKDIR /home/ctfuser
CMD ["bash"]
EOF

docker build -t "$IMG" "$CTX" >/dev/null
echo "Built image: $IMG"
