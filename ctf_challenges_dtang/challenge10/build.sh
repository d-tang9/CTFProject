#!/usr/bin/env bash
set -euo pipefail

IMAGE="challenge10:latest"
CONTAINER="challenge10"

# Fresh workspace
rm -rf app
mkdir -p app

########################################
# Challenge content
########################################

# Root-only flag
cat > app/flag.txt <<'FLAG'
flag{suid_path_hijack_works}
FLAG

# Player breadcrumb in home
cat > app/README.txt <<'READ'
[ Operations Note ]
The "vuln" utility writes an audit entry using `logger`.
If logger is unavailable, it may fail silently.

(Dev todo: make sure PATH is set correctly before running it.)
READ

# Extra breadcrumb
mkdir -p app/opt/notes
cat > app/opt/notes/sysadmin_note.txt <<'NOTE'
Reminder: Hardcode full paths for any privileged tool that calls other programs.
Example: use /usr/bin/logger instead of logger. Also keep PATH safe.
NOTE

# Vulnerable C program (calls 'logger' with no full path)
cat > app/vuln.c <<'C'
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>

int main(void) {
    // Minimal SUID "do something then log" demo.
    // Calls 'logger' without a full path → PATH hijack.
    int rc = system("logger -t vuln 'user ran vuln'");
    if (rc == -1) {
        perror("system");
    } else if (rc != 0) {
        fprintf(stderr, "logger exited with code %d\n", rc);
    }
    // Pretend to succeed regardless; this keeps the binary simple.
    return 0;
}
C

# Dockerfile (multi-stage: compile, then copy into slim Alpine)
cat > app/Dockerfile <<'DOCKER'
FROM alpine:3.20 AS builder
RUN apk add --no-cache build-base
WORKDIR /src
COPY vuln.c .
RUN gcc -O2 -s -o vuln vuln.c

FROM alpine:3.20
# Bash for consistency with your series; logger for realism
RUN apk add --no-cache bash busybox-initscripts
# Create non-root player
RUN adduser -D -h /home/ctfuser ctfuser
# Flag (root-only)
COPY flag.txt /root/flag.txt
RUN chmod 600 /root/flag.txt
# Breadcrumbs
COPY README.txt /home/ctfuser/README.txt
RUN chown ctfuser:ctfuser /home/ctfuser/README.txt
RUN mkdir -p /opt/notes && chmod 755 /opt/notes
COPY opt/notes/sysadmin_note.txt /opt/notes/sysadmin_note.txt
# Vulnerable SUID binary
COPY --from=builder /src/vuln /usr/local/bin/vuln
# Own by root and setuid
RUN chown root:root /usr/local/bin/vuln && chmod 4755 /usr/local/bin/vuln
# Keep container up for manual play; users will exec in
USER ctfuser
WORKDIR /home/ctfuser
CMD ["bash","-lc","while :; do sleep 3600; done"]
DOCKER

########################################
# Build & run
########################################
docker rm -f "$CONTAINER" >/dev/null 2>&1 || true
docker rmi "$IMAGE" >/dev/null 2>&1 || true

docker build -t "$IMAGE" app
docker run -d --name "$CONTAINER" --hostname "$CONTAINER" "$IMAGE"

echo "[+] Challenge 10 up."
echo "    docker exec -it $CONTAINER /bin/bash"
echo "    Look at /home/ctfuser/README.txt and /opt/notes/sysadmin_note.txt"
