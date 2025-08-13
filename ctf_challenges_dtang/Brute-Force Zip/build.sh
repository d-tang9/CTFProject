#!/usr/bin/env bash
set -euo pipefail

IMAGE="ctf-brute-force-zip:latest"
CTX="$(cd "$(dirname "$0")" && pwd)/build_ctx"

# Fresh context
rm -rf "$CTX"
mkdir -p "$CTX"

# --- Dockerfile + in-image build of the zip (no host deps) ---
cat >"$CTX/Dockerfile" <<'DOCKER'
FROM alpine:3.20

# Keep it lightweight, but we need bash, zip/unzip
RUN apk add --no-cache bash zip unzip coreutils

# Non-root user with Bash shell
RUN adduser -D -s /bin/bash ctfuser
USER ctfuser
WORKDIR /home/ctfuser

# Breadcrumbs (players will see these immediately)
# - README.txt: explains there's a passworded zip and a wordlist
# - NOTICE.txt: extra nudge toward trying a simple brute-force with the wordlist
# - wordlist.txt: includes the real password mixed with decoys
RUN cat > README.txt <<'EOF'
[Backup Ticket #BR-1007]
We zipped a small text file but forgot the password.
The only clue left is this "wordlist.txt". Recover the file in "secret.zip".
You do NOT need internet or extra tools beyond what's here.
EOF

RUN cat > NOTICE.txt <<'EOF'
Hint: "wordlist.txt" probably contains the password.
Try passwords from the list against "secret.zip" until one works.
EOF

# Build the challenge artifacts inside a single layer so the plain flag never
# persists in an older layer
# Password is one of the wordlist entries: lol123
RUN set -eux; \
    cat > wordlist.txt <<'WL' && \
    truepassword=lol123 && \
    printf 'flag{bruteforce_zip}\n' > flag.txt && \
    zip -P "${truepassword}" -q secret.zip flag.txt && \
    shred -u flag.txt
password
123456
qwerty
letmein
lol123
secret
winter2025
dragon
WL

# Default shell so the container stays interactive for players
# CMD ["/bin/bash"]
CMD ["sleep","infinity"]
DOCKER

# Build
docker build -t "$IMAGE" "$CTX"
echo "Built image: $IMAGE"
