FROM alpine:3.20
RUN apk add --no-cache bash coreutils build-base

RUN addgroup -S ctf && adduser -S -G ctf -s /bin/bash ctfuser

WORKDIR /opt
COPY app/check_flag.sh /opt/check_flag.sh
COPY app/flag.txt /root/flag.txt
COPY app/README.txt /home/ctfuser/README.txt
COPY app/ctfuser.bashrc /home/ctfuser/.bashrc
COPY app/ctfuser.bash_profile /home/ctfuser/.bash_profile
COPY app/readflag.c /usr/local/src/readflag.c

RUN chmod 600 /root/flag.txt && chown root:root /root/flag.txt && \
    chown ctfuser:ctf /home/ctfuser/README.txt /home/ctfuser/.bashrc /home/ctfuser/.bash_profile && \
    chmod 755 /opt/check_flag.sh

RUN gcc -O2 -s -o /usr/local/bin/readflag /usr/local/src/readflag.c && \
    chown root:root /usr/local/bin/readflag && chmod 4755 /usr/local/bin/readflag && \
    rm -rf /usr/local/src/*

RUN sha256sum /opt/check_flag.sh | awk '{print $1}' > /opt/check_flag.sha256 && \
    chown root:root /opt/check_flag.sha256 && chmod 444 /opt/check_flag.sha256

RUN apk del build-base || true

USER ctfuser
WORKDIR /home/ctfuser
CMD ["/bin/bash", "-l"]
