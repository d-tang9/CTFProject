FROM alpine:3.20

# Need bash for scripts. (Busybox provides crond.)
RUN apk add --no-cache bash

# Create non-root player and workspace
RUN adduser -D -s /bin/bash ctfuser

# Flag (root only)
COPY flag.txt /root/flag.txt
RUN chmod 600 /root/flag.txt

# Vulnerable cleanup + breadcrumbs
COPY cleanup.sh /usr/local/bin/cleanup.sh
RUN chmod 755 /usr/local/bin/cleanup.sh
RUN mkdir -p /var/cleanup /var/log && chmod 0777 /var/cleanup

# Breadcrumb for players
COPY NOTICE.txt /home/ctfuser/NOTICE.txt
RUN chown -R ctfuser:ctfuser /home/ctfuser

# Root crontab (Alpine style)
# Runs every minute, logs to /var/log/cleanup.log
RUN echo '* * * * * /bin/bash /usr/local/bin/cleanup.sh >> /var/log/cleanup.log 2>&1' > /etc/crontabs/root

# Keep cron running (use the correct spool dir) and keep the container alive
CMD ["/bin/bash","-lc","/usr/sbin/crond -l 8 -c /etc/crontabs; tail -f /dev/null"]
