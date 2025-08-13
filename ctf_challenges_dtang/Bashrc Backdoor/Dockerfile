FROM ubuntu:22.04

# Create non-root user
RUN useradd -m -s /bin/bash ctfuser

# Flag with strict perms
COPY flag.txt /root/flag.txt
RUN chmod 600 /root/flag.txt

# Tools
RUN apt-get update && apt-get install -y --no-install-recommends bash coreutils sudo \
    && rm -rf /var/lib/apt/lists/*

# Install helper and sudoers rule
COPY app/leak_once.sh /usr/local/bin/leak_once.sh
RUN chown root:root /usr/local/bin/leak_once.sh && chmod 0755 /usr/local/bin/leak_once.sh
COPY app/sudoers.d/ctfuser /etc/sudoers.d/ctfuser
RUN chmod 0440 /etc/sudoers.d/ctfuser

# User home files
COPY app/.bashrc /home/ctfuser/.bashrc
COPY app/root.bashrc /home/ctfuser/root.bashrc
RUN chown ctfuser:ctfuser /home/ctfuser/.bashrc /home/ctfuser/root.bashrc

# Disable root login
RUN chsh -s /usr/sbin/nologin root && passwd -l root || true

# Default to ctfuser so `docker exec -it ... bash` lands as ctfuser
USER ctfuser
WORKDIR /home/ctfuser

# Start entrypoint (as ctfuser)
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
