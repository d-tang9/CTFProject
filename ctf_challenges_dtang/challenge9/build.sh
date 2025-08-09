#!/usr/bin/env bash
set -euo pipefail
IMG="ctf_ch9_cron"
CTX="$(cd "$(dirname "$0")" && pwd)"/build_ctx
rm -rf "$CTX"; mkdir -p "$CTX/app"

cat >"$CTX/flag.txt" <<'EOF'
flag{cron_injection}
EOF

cat >"$CTX/app/cleanup.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
for f in /var/cleanup/*; do
  [ -x "$f" ] && bash "$f" || true
done
EOF
chmod +x "$CTX/app/cleanup.sh"

cat >"$CTX/Dockerfile" <<'EOF'
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y cron bash && rm -rf /var/lib/apt/lists/*
COPY flag.txt /root/flag.txt
RUN chmod 600 /root/flag.txt
RUN useradd -m -s /bin/bash ctfuser
RUN mkdir -p /var/cleanup && chmod 777 /var/cleanup
COPY app/cleanup.sh /usr/local/bin/cleanup.sh
RUN chmod 755 /usr/local/bin/cleanup.sh
RUN echo '* * * * * root /usr/local/bin/cleanup.sh' >> /etc/crontab
USER ctfuser
WORKDIR /home/ctfuser
CMD ["bash","-lc","service cron start && bash"]
EOF

docker build -t "$IMG" "$CTX" >/dev/null
echo "Built image: $IMG"
