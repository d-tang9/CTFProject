FROM ubuntu:22.04

# Create non-root user
RUN useradd -m -s /bin/bash ctfuser

# Stage the root-only flag
COPY flag.txt /root/flag.txt
RUN chmod 600 /root/flag.txt

# Put backup script in place and run it as root to generate the weak backup
COPY app/backup.sh /usr/local/bin/backup.sh
RUN chmod +x /usr/local/bin/backup.sh \
 && mkdir -p /var/backups \
 && /usr/local/bin/backup.sh \
 # Hide directory listing but allow path traversal by known filename
 && chmod 711 /var/backups

# Drop to non-root for players
USER ctfuser
WORKDIR /home/ctfuser

# Keep the container running so players can attach later
CMD ["tail","-f","/dev/null"]

