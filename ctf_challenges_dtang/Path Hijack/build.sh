#!/usr/bin/env bash
set -euo pipefail

IMAGE="ctf-path-hijack:latest"
CONTAINER="ctf-path-hijack"

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
#include <unistd.h>
#include <stdio.h>

int main(void) {
    // make sure we’re really root (euid already root due to SUID)
    if (setgid(0) != 0 || setuid(0) != 0) {
        perror("setuid/setgid");
        return 1;
    }

    // Call 'logger' directly; PATH will be searched (vulnerable!)
    char *argv[] = {"logger", "-t", "vuln", "user ran vuln", NULL};
    execvp("logger", argv);

    // If we get here, exec failed
    perror("execvp");
    return 127;
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
# Bash for consistency; BusyBox already includes `logger`
RUN apk add --no-cache bash
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
RUN chown root:root /usr/local/bin/vuln && chmod 4755 /usr/local/bin/vuln
# Keep container up for manual play
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
