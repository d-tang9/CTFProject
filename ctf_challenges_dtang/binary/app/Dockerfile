# ---- builder ----
FROM golang:1.22-alpine AS builder
WORKDIR /src
COPY checkpass.go .
ENV CGO_ENABLED=0
RUN go build -ldflags="-s -w" -o /out/checkpass checkpass.go && ls -l /out/checkpass

# ---- runtime ----
FROM alpine:3.20
RUN apk add --no-cache bash binutils
RUN adduser -D -s /bin/bash ctfuser
WORKDIR /home/ctfuser

COPY --from=builder /out/checkpass /home/ctfuser/checkpass
RUN chmod 0555 /home/ctfuser/checkpass && chown ctfuser:ctfuser /home/ctfuser/checkpass

USER ctfuser
RUN printf '%s\n' \
  "Goal: get the flag from ./checkpass" \
  "Tip: Try static inspection (e.g., strings) first." \
  "Breadcrumb format: PWD=[...]" \
  > README.txt

CMD ["/bin/bash", "-l"]
