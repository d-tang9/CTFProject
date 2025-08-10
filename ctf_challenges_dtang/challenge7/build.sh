#!/bin/bash
set -euo pipefail

# Challenge name and image tag
CHAL_NAME="challenge7"
IMG_TAG="ctf-${CHAL_NAME}"

# Fresh build context
rm -rf "${CHAL_NAME}"
mkdir -p "${CHAL_NAME}/app"

# Files staged into /app (inside the image)
cat > "${CHAL_NAME}/app/check_flag.sh" <<'EOF'
#!/bin/bash
set -euo pipefail

UNLOCK_HHMM="04:00"                 # breadcrumbed in ~/README.txt
SELF="/opt/check_flag.sh"
SIG="/opt/check_flag.sha256"
READER="/usr/local/bin/readflag"

# 1) Integrity check
if [[ ! -r "$SIG" ]]; then
  echo "Integrity signature missing. Aborting."
  exit 1
fi
self_sum="$(sha256sum "$SELF" | awk '{print $1}')"
expected_sum="$(cat "$SIG" | tr -d '\n' | tr -d '\r')"
if [[ "$self_sum" != "$expected_sum" ]]; then
  echo "Tampering detected. Aborting."
  exit 1
fi

# 2) Time check
now="$(date +%H:%M)"
if [[ "$now" != "$UNLOCK_HHMM" ]]; then
  echo "Access denied: window locked (now=$now, need=$UNLOCK_HHMM)."
  exit 1
fi

# 3) Print the flag via the minimal setuid helper
exec "$READER"
EOF
chmod +x "${CHAL_NAME}/app/check_flag.sh"

# Root-only flag (will land at /root/flag.txt)
cat > "${CHAL_NAME}/app/flag.txt" <<'EOF'
flag{time_and_integrity_ftw}
EOF

# Breadcrumbs and path prepender
cat > "${CHAL_NAME}/app/README.txt" <<'EOF'
Welcome to Challenge 7.

Notes from support:
- Unlock window for verification is at exactly 04:00 (HH:MM).
- Ops sometimes use wrapper scripts located in $HOME/bin which take precedence over system binaries.
- Integrity matters here; unexpected changes will be rejected.

Good luck!
EOF

cat > "${CHAL_NAME}/app/ctfuser.bashrc" <<'EOF'
# Prepend per-user tools; this is a breadcrumb.
mkdir -p "$HOME/bin"
export PATH="$HOME/bin:$PATH"
# Friendly prompt
PS1='[ctf7:\w]\$ '
EOF

# Minimal setuid C helper to read /root/flag.txt safely
cat > "${CHAL_NAME}/app/readflag.c" <<'EOF'
#include <stdio.h>
#include <stdlib.h>

int main(void) {
    FILE *f = fopen("/root/flag.txt", "r");
    if (!f) {
        perror("open flag");
        return 1;
    }
    int c;
    while ((c = fgetc(f)) != EOF) putchar(c);
    fclose(f);
    return 0;
}
EOF

# Dockerfile (Alpine + Bash, consistent with other challenges)
cat > "${CHAL_NAME}/Dockerfile" <<'EOF'
FROM alpine:3.20

# Tools: bash for shell, coreutils for sha256sum, build-base to compile tiny helper
RUN apk add --no-cache bash coreutils build-base

# Create non-root player
RUN addgroup -S ctf && adduser -S -G ctf -s /bin/bash ctfuser

# Stage app
WORKDIR /opt
COPY app/check_flag.sh /opt/check_flag.sh
COPY app/flag.txt /root/flag.txt
COPY app/README.txt /home/ctfuser/README.txt
COPY app/ctfuser.bashrc /home/ctfuser/.bashrc
COPY app/readflag.c /usr/local/src/readflag.c

# Permissions: root-only flag; player-readable app
RUN chmod 600 /root/flag.txt && \
    chown root:root /root/flag.txt && \
    chown ctfuser:ctf /home/ctfuser/README.txt /home/ctfuser/.bashrc && \
    chmod 755 /opt/check_flag.sh

# Build minimal setuid helper and lock it down
RUN gcc -O2 -s -o /usr/local/bin/readflag /usr/local/src/readflag.c && \
    chown root:root /usr/local/bin/readflag && \
    chmod 4755 /usr/local/bin/readflag && \
    rm -rf /usr/local/src/*

# Create integrity signature AFTER finalizing the script on disk
RUN sha256sum /opt/check_flag.sh | awk '{print $1}' > /opt/check_flag.sha256 && \
    chown root:root /opt/check_flag.sha256 && chmod 444 /opt/check_flag.sha256

# Drop build deps to keep size smaller (optional)
RUN apk del build-base || true

# Default to the player user with an interactive bash
USER ctfuser
WORKDIR /home/ctfuser
CMD ["/bin/bash", "-l"]
EOF

# Build and run
docker build -t "${IMG_TAG}" "${CHAL_NAME}"
# Keep container up for players to attach
docker rm -f "${CHAL_NAME}" >/dev/null 2>&1 || true
docker run -d --name "${CHAL_NAME}" -it "${IMG_TAG}" >/dev/null

echo "Built and started ${CHAL_NAME}. Attach with:  docker exec -it ${CHAL_NAME} /bin/bash"
