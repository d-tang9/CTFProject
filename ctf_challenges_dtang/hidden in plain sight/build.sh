#!/usr/bin/env bash
set -euo pipefail

CHALLENGE_NAME="ctf-hidden-in-plain-sight"
IMAGE_NAME="ctf-hidden-in-plain-sight:latest"
CONTAINER_NAME="ctf-hidden-in-plain-sight"

# Clean old artifacts quietly
docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
docker rmi "$IMAGE_NAME" >/dev/null 2>&1 || true
rm -f Dockerfile flag.txt >/dev/null 2>&1 || true

# Challenge flag (edit if you like)
FLAG="flag{hidden_in_plain_sight}"

# Write Dockerfile with Bash + tools and durable container
cat > Dockerfile <<'DOCKERFILE'
FROM alpine:3.20

# Bash for consistency, binutils for `strings`, shadow for `useradd`
RUN apk add --no-cache bash binutils shadow

# Create non-root user that uses Bash
RUN useradd -m -s /bin/bash ctfuser

# Work in user's home
WORKDIR /home/ctfuser

# Build args
ARG FLAG_VALUE
ARG OFFSET

# Create data and breadcrumbs during build
RUN set -eux; \
    # 1 KiB random data
    dd if=/dev/urandom of=random.bin bs=1024 count=1 status=none; \
    # Embed the flag at fixed offset without truncating
    printf "%s\n" "${FLAG_VALUE}" | dd of=random.bin bs=1 seek="${OFFSET}" conv=notrunc status=none; \
    # Compute hex name of "note_flag.txt" using od (portable on BusyBox)
    HEX_NAME="$(printf 'note_flag.txt' | od -An -t x1 | tr -d ' \n')"; \
    # Rename to the hex-y filename
    mv random.bin "${HEX_NAME}"; \
    # Breadcrumbs
    printf "You are in a staging home.\nSome files may use hex-looking names.\nTry basic forensic steps (strings/grep/hexdump) on suspicious files.\n" > /home/ctfuser/README.txt; \
    mkdir -p /var/log/app; \
    printf "2025-08-10 09:00:00 rename: note_flag.txt -> %s\n" "${HEX_NAME}" > /var/log/app/rename.log; \
    # Permissions
    chown -R ctfuser:ctfuser /home/ctfuser /var/log/app; \
    chmod 640 /var/log/app/rename.log; \
    # Soft hint
    printf "# hint: hex names + strings are your friends\n" >> /home/ctfuser/.bash_history

USER ctfuser
WORKDIR /home/ctfuser

# Keep container alive for manual exploration; Bash for consistency
CMD ["bash", "-lc", "echo 'Challenge6 ready. Try: ls -l, cat README.txt, strings * | grep -i flag'; tail -f /dev/null"]
DOCKERFILE

# Offset to embed the flag
OFFSET=500

# Write the flag locally (not copied directly—only embedded into data)
printf "%s\n" "$FLAG" > flag.txt

echo "[*] Building image ${IMAGE_NAME} ..."
docker build \
  --build-arg FLAG_VALUE="$FLAG" \
  --build-arg OFFSET="$OFFSET" \
  -t "$IMAGE_NAME" .

echo "[*] Starting container ${CONTAINER_NAME} ..."
docker run -d --name "$CONTAINER_NAME" "$IMAGE_NAME" >/dev/null

#echo "[*] Container is up."
#echo "    Solve manually with:"
#echo "      docker exec -it ${CONTAINER_NAME} /bin/bash"
#echo "      ls -la ; cat README.txt ; strings * | grep -i flag"
