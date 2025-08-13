FROM alpine:3.20
RUN apk add --no-cache bash coreutils grep findutils
RUN adduser -D -s /bin/bash ctfuser
WORKDIR /home/ctfuser
COPY homefiles/ /home/ctfuser/
RUN chown -R ctfuser:ctfuser /home/ctfuser && chmod 444 /home/ctfuser/*.txt
USER ctfuser
# CMD ["bash"]
CMD ["sleep","infinity"]
