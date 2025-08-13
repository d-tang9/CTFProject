FROM ubuntu:22.04

# Create non-root user
RUN useradd -m -s /bin/bash ctfuser

# Place flag with strict perms, then precreate /tmp/.cachefile from it
COPY flag.txt /root/flag.txt
RUN chmod 600 /root/flag.txt \
 && ( umask 022; cp /root/flag.txt /tmp/.cachefile ) \
 && chmod 0644 /tmp/.cachefile

# Tools
RUN apt-get update && apt-get install -y --no-install-recommends bash coreutils \
    && rm -rf /var/lib/apt/lists/*

# User home files (clue + normal bashrc)
COPY app/.bashrc /home/ctfuser/.bashrc
COPY app/root.bashrc /home/ctfuser/root.bashrc
RUN chown ctfuser:ctfuser /home/ctfuser/.bashrc /home/ctfuser/root.bashrc

# Disable root login
RUN chsh -s /usr/sbin/nologin root && passwd -l root || true

# Default to ctfuser so `docker exec -it ... bash` lands as ctfuser
USER ctfuser
WORKDIR /home/ctfuser

# Keep container alive for interactive play if run detached
CMD ["bash","-lc","sleep infinity"]
