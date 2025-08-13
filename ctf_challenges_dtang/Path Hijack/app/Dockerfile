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
