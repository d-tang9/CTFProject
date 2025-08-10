#!/usr/bin/env bash
set -euo pipefail

CHALLENGE_NAME="challenge8"
IMAGE_NAME="ctf-${CHALLENGE_NAME}:latest"
CONTAINER_NAME="${CHALLENGE_NAME}"

# Prepare build context
rm -rf app
mkdir -p app

# Go source (kept only in build context; not shipped in final image)
cat > app/checkpass.go << 'EOF'
package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

const flag = "flag{rev_binary_basic}"
// IMPORTANT: We keep a referenced hint so the compiler doesn't drop it.
// This leaves a breadcrumb for players using `strings`.
var hint = "PWD=fbujm38@db"

func main() {
	// Reference the hint so it is retained in the binary.
	if len(hint) == 0 {
		fmt.Print("")
	}

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

# Dockerfile (multi-stage: build -> minimal runtime)
cat > app/Dockerfile << 'EOF'
# ---- builder ----
FROM golang:1.22-alpine AS builder
WORKDIR /src
COPY checkpass.go .
# Build a small, stripped, static binary
ENV CGO_ENABLED=0
RUN go build -ldflags="-s -w" -o /out/checkpass checkpass.go && \
    ls -l /out/checkpass

# ---- runtime ----
FROM alpine:3.20
# Keep it light but usable for RE: bash + binutils(strings)
RUN apk add --no-cache bash binutils
# Create non-root user with bash shell
RUN adduser -D -s /bin/bash ctfuser
USER ctfuser
WORKDIR /home/ctfuser

# Breadcrumb for players
COPY --from=builder /out/checkpass ./checkpass
RUN chmod 0555 ./checkpass

# Add a small hint file (not too revealing)
RUN printf '%s\n' \
  "Goal: get the flag from ./checkpass" \
  "Tip: You might not need to run it first—try simple static inspection tools." \
  "Remember: human-readable strings inside binaries can be… enlightening." \
  > README.txt

# Drop into an interactive bash so the container stays up for players
CMD ["/bin/bash", "-l"]
EOF

# Build image
docker build -t "${IMAGE_NAME}" ./app

# Clean prior container if exists
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  docker rm -f "${CONTAINER_NAME}" >/dev/null 2>&1 || true
fi

# Run container (detached interactive so it persists)
docker run -dit --name "${CONTAINER_NAME}" "${IMAGE_NAME}" >/dev/null

echo "Built and started ${CONTAINER_NAME}. To play:"
echo "  docker exec -it ${CONTAINER_NAME} /bin/bash"
echo "Inside container, see: ~/checkpass and ~/README.txt"
