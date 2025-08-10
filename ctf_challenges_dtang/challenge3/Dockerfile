FROM ubuntu:22.04

# Minimal packages for building the SUID helper
RUN apt-get update && apt-get install -y --no-install-recommends gcc libc6-dev && \
    rm -rf /var/lib/apt/lists/*

# Create the non-root user
RUN useradd -m -u 1000 ctfuser

# Put the flag in root's home (root-only permissions)
COPY flag.txt /root/flag.txt
RUN chmod 600 /root/flag.txt

# Build a tiny SUID root helper that copies the flag to /tmp/.cachefile
# NOTE: setuid only works on binaries, not on shell scripts.
RUN cat > /tmp/copyflag.c <<'EOF'\n\
#include <stdio.h>\n\
#include <stdlib.h>\n\
#include <unistd.h>\n\
#include <fcntl.h>\n\
#include <sys/stat.h>\n\
#include <errno.h>\n\
int main(void){\n\
    const char *src = \"/root/flag.txt\";\n\
    const char *dst = \"/tmp/.cachefile\";\n\
    int in = open(src, O_RDONLY);\n\
    if(in < 0){perror(\"open src\"); return 1;}\n\
    int out = open(dst, O_WRONLY|O_CREAT|O_TRUNC, 0644);\n\
    if(out < 0){perror(\"open dst\"); close(in); return 1;}\n\
    char buf[4096]; ssize_t n;\n\
    while((n = read(in, buf, sizeof buf)) > 0){\n\
        if(write(out, buf, n) != n){perror(\"write\"); close(in); close(out); return 1;}\n\
    }\n\
    if(n < 0){perror(\"read\");}\n\
    close(in); close(out);\n\
    return n<0; \n\
}\n\
EOF\n\
 && gcc -O2 -s /tmp/copyflag.c -o /usr/local/bin/copyflag \
 && chown root:root /usr/local/bin/copyflag \
 && chmod 4755 /usr/local/bin/copyflag \
 && rm -f /tmp/copyflag.c

# Backdoor in ctfuser's shell startup
COPY app/.bashrc /home/ctfuser/.bashrc
COPY app/.bash_profile /home/ctfuser/.bash_profile
RUN chown -R ctfuser:ctfuser /home/ctfuser

USER ctfuser
# Keep the container running for exec-based interaction
CMD ["tail", "-f", "/dev/null"]
