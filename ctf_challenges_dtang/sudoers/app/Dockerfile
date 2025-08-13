FROM ubuntu:22.04

# Minimal tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo less ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# Add a non-root user
RUN useradd -m -s /bin/bash ctfuser

# Put the flag in /root with tight permissions
COPY flag.txt /root/flag.txt
RUN chown root:root /root/flag.txt && chmod 600 /root/flag.txt

# Configure sudoers: allow only /usr/bin/less without password
COPY ctfuser_sudoers /etc/sudoers.d/ctfuser
RUN chown root:root /etc/sudoers.d/ctfuser && chmod 0440 /etc/sudoers.d/ctfuser

# Default to ctfuser
USER ctfuser
WORKDIR /home/ctfuser

# Keep the container running so players have time to solve
CMD ["sleep", "infinity"]
