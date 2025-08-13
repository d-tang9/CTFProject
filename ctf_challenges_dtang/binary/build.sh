#!/usr/bin/env bash
set -euo pipefail

CHALLENGE_NAME="ctf-binary"
IMAGE_NAME="${CHALLENGE_NAME}:latest"
CONTAINER_NAME="${CHALLENGE_NAME}"

rm -rf app
mkdir -p app

cat > app/checkpass.go << 'EOF'
package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

const flag = "flag{rev_binary_basic}"
// Delimited breadcrumb so `strings` shows a clean token:
var hint = "PWD=[fbujm38@db]\n"

func main() {
	// Reference the hint so it is retained in the binary.
	if len(hint) == 0 { fmt.Print("") }

	reader := bufio.NewReader(os.Stdin)
	fmt.Print("Enter password: ")
	in, _ := reader.ReadString('\n')
	in = strings.TrimSpace(in)

	if in == "fbujm38@db" {
		fmt.Println(flag)
	} else {
		fmt.Println("Incorrect password.")
	}
}
EOF

cat > app/Dockerfile << 'EOF'
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
EOF

docker build -t "${IMAGE_NAME}" ./app

if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true
fi

docker run -dit --name "${CONTAINER_NAME}" "${IMAGE_NAME}" >/dev/null

echo "Built and started ${CONTAINER_NAME}. To play:"
echo "  docker exec -it ${CONTAINER_NAME} /bin/bash"
echo "Inside: ~/checkpass and ~/README.txt"
