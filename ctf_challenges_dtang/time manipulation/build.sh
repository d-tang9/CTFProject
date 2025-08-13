#!/bin/bash
set -euo pipefail

CHAL_NAME="challenge7"
IMG_TAG="${CHAL_NAME}"

rm -rf "${CHAL_NAME}"
mkdir -p "${CHAL_NAME}/app"

cat > "${CHAL_NAME}/app/check_flag.sh" <<'EOF'
#!/bin/bash
set -euo pipefail

UNLOCK_HHMM="04:00"
SELF="/opt/check_flag.sh"
SIG="/opt/check_flag.sha256"
READER="/usr/local/bin/readflag"

if [[ ! -r "$SIG" ]]; then
  echo "Integrity signature missing. Aborting."
  exit 1
fi

self_sum="$(sha256sum "$SELF" | awk '{print $1}')"
expected_sum="$(tr -d '\r\n' < "$SIG")"
if [[ "$self_sum" != "$expected_sum" ]]; then
  echo "Tampering detected. Aborting."
  exit 1
fi

now="$(date +%H:%M)"
if [[ "$now" != "$UNLOCK_HHMM" ]]; then
  echo "Access denied: window locked (now=$now, need=$UNLOCK_HHMM)."
  exit 1
fi

exec "$READER"
EOF
chmod +x "${CHAL_NAME}/app/check_flag.sh"

cat > "${CHAL_NAME}/app/flag.txt" <<'EOF'
flag{time_and_integrity_ftw}
EOF

cat > "${CHAL_NAME}/app/README.txt" <<'EOF'
Welcome to Challenge 7.

Notes from support:
- Unlock window for verification is at exactly 04:00 (HH:MM).
- Ops sometimes use wrapper scripts located in $HOME/bin which take precedence over system binaries.
- Integrity matters here; unexpected changes will be rejected.

Good luck!
EOF

# Bash config: .bashrc (breadcrumb) + .bash_profile to source it for login shells
cat > "${CHAL_NAME}/app/ctfuser.bashrc" <<'EOF'
mkdir -p "$HOME/bin"
export PATH="$HOME/bin:$PATH"
PS1='[ctf7:\w]\$ '
EOF

cat > "${CHAL_NAME}/app/ctfuser.bash_profile" <<'EOF'
# Ensure login shells also load our breadcrumbs
if [ -f "$HOME/.bashrc" ]; then
  . "$HOME/.bashrc"
fi
EOF

cat > "${CHAL_NAME}/app/readflag.c" <<'EOF'
#include <stdio.h>
int main(void) {
    FILE *f = fopen("/root/flag.txt", "r");
    if (!f) return 1;
    int c; while ((c = fgetc(f)) != EOF) putchar(c);
    fclose(f);
    return 0;
}
EOF

cat > "${CHAL_NAME}/Dockerfile" <<'EOF'
FROM alpine:3.20
RUN apk add --no-cache bash coreutils build-base

RUN addgroup -S ctf && adduser -S -G ctf -s /bin/bash ctfuser

WORKDIR /opt
COPY app/check_flag.sh /opt/check_flag.sh
COPY app/flag.txt /root/flag.txt
COPY app/README.txt /home/ctfuser/README.txt
COPY app/ctfuser.bashrc /home/ctfuser/.bashrc
COPY app/ctfuser.bash_profile /home/ctfuser/.bash_profile
COPY app/readflag.c /usr/local/src/readflag.c

RUN chmod 600 /root/flag.txt && chown root:root /root/flag.txt && \
    chown ctfuser:ctf /home/ctfuser/README.txt /home/ctfuser/.bashrc /home/ctfuser/.bash_profile && \
    chmod 755 /opt/check_flag.sh

RUN gcc -O2 -s -o /usr/local/bin/readflag /usr/local/src/readflag.c && \
    chown root:root /usr/local/bin/readflag && chmod 4755 /usr/local/bin/readflag && \
    rm -rf /usr/local/src/*

RUN sha256sum /opt/check_flag.sh | awk '{print $1}' > /opt/check_flag.sha256 && \
    chown root:root /opt/check_flag.sha256 && chmod 444 /opt/check_flag.sha256

RUN apk del build-base || true

USER ctfuser
WORKDIR /home/ctfuser
CMD ["/bin/bash", "-l"]
EOF

docker build -t "${IMG_TAG}" "${CHAL_NAME}"
docker rm -f "${CHAL_NAME}" >/dev/null 2>&1 || true
docker run -d --name "${CHAL_NAME}" -it "${IMG_TAG}" >/dev/null

echo "Built and started ${CHAL_NAME}. Attach with:  docker exec -it ${CHAL_NAME} /bin/bash"
