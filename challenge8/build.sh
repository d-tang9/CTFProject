    #!/usr/bin/env bash
    set -euo pipefail
    IMG="ctf_ch8_rev_go"
    CTX="$(cd "$(dirname "$0")" && pwd)"/build_ctx
    rm -rf "$CTX"; mkdir -p "$CTX"

    cat >"$CTX/Dockerfile" <<'EOF'
    # build stage
    FROM golang:1.22 as builder
    WORKDIR /src
    RUN printf '%s
' 'package main' 'import ("bufio";"fmt";"os")' 'func main(){'         'in:=bufio.NewScanner(os.Stdin); in.Scan();'         'if in.Text()=="fbujm38@db" { fmt.Println("flag{re_strings_go}") } else { fmt.Println("nope") }'         '}' > checkpass.go
    RUN go build -ldflags="-s -w" -o /out/checkpass checkpass.go

    # runtime stage
    FROM ubuntu:22.04
    RUN apt-get update && apt-get install -y bash binutils && rm -rf /var/lib/apt/lists/*
    RUN useradd -m -s /bin/bash ctfuser
    WORKDIR /home/ctfuser
    COPY --from=builder /out/checkpass ./checkpass
    RUN chown -R ctfuser:ctfuser /home/ctfuser && chmod 555 /home/ctfuser/checkpass
    USER ctfuser
    CMD ["bash"]
    EOF

    docker build -t "$IMG" "$CTX" >/dev/null
    echo "Built image: $IMG"
