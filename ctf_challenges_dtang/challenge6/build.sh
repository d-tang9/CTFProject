#!/usr/bin/env bash
set -euo pipefail

CHALLENGE_NAME="challenge6"
IMAGE_NAME="challenge6:latest"
CONTAINER_NAME="challenge6"

# Clean old stuff quietly
docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
docker rmi "$IMAGE_NAME" >/dev/null 2>&1 || true
rm -f Dockerfile flag.txt >/dev/null 2>&1 || true

# Choose a flag (edit if you want)
FLAG="flag{hidden_in_plain_sight}"

# Stage a Dockerfile that builds everything deterministically
cat > Dockerfile <<'DOCKERFILE'
FROM alpine:3.20

# Need strings from binutils; busybox provides xxd/hexdump; add sudo-less user
RUN apk add --no-cache binutils shadow

# Create non-root user
RUN useradd -m -s /bin/sh ctfuser

# Work in user's home
WORKDIR /home/ctfuser

# Copy the build-time helper script (created below via heredoc at build time)
# We'll generate the binary file and breadcrumbs during image build.
# The flag will be injected with dd at a fixed offset.
ARG FLAG_VALUE
ARG HEX_NAME
ARG OFFSET

# Prepare files and breadcrumbs during build
RUN set -eux; \
    # 1 KiB of random data
    dd if=/dev/urandom of=random.bin bs=1024 count=1 status=none; \
    # Embed the flag at chosen offset without truncating
    printf "%s\n" "${FLAG_VALUE}" | dd of=random.bin bs=1 seek="${OFFSET}" conv=notrunc status=none; \
    # Rename random.bin to a hex-encoded "note_flag.txt" to create a weird filename breadcrumb
    mv random.bin "${HEX_NAME}"; \
    # Breadcrumbs: a tiny README and an ops log mentioning hex renames (not the offset)
    printf "You are in a staging home.\nSome files may use hex-looking names.\nTry basic forensic steps (strings/grep/xxd) on suspicious files.\n" > /home/ctfuser/README.txt; \
    mkdir -p /var/log/app; \
    printf "2025-08-10 09:00:00 rename: note_flag.txt -> %s\n" "${HEX_NAME}" > /var/log/app/rename.log; \
    # Lock down perms reasonably but leave readable to ctfuser
    chown -R ctfuser:ctfuser /home/ctfuser /var/log/app; \
    chmod 640 /var/log/app/rename.log; \
    # Quality-of-life: shell history hint (soft breadcrumb)
    printf "# hint: hex names + strings are your friends\n" >> /home/ctfuser/.shhint

USER ctfuser
WORKDIR /home/ctfuser

# Keep the container alive for manual exploration
CMD ["sh", "-lc", "echo 'Challenge6 ready. Try: ls -l, cat README.txt, strings * | grep -i flag'; tail -f /dev/null"]
DOCKERFILE

# Prepare build args
# The obfuscated filename is hex("note_flag.txt")
HEX_NAME="$(printf 'note_flag.txt' | xxd -p -c 256)"
# Fixed offset (matches the write-up idea; doesn't have to be round)
OFFSET=500

# Write the flag to a local file (not baked into image as a file—only embedded in data)
printf "%s\n" "$FLAG" > flag.txt

echo "[*] Building image ${IMAGE_NAME} ..."
docker build \
  --build-arg FLAG_VALUE="$FLAG" \
  --build-arg HEX_NAME="$HEX_NAME" \
  --build-arg OFFSET="$OFFSET" \
  -t "$IMAGE_NAME" .

echo "[*] Starting container ${CONTAINER_NAME} ..."
docker run -d --name "$CONTAINER_NAME" "$IMAGE_NAME" >/dev/null

#echo "[*] Container is up."
#echo "    Try: docker exec -it ${CONTAINER_NAME} /bin/sh"
#echo "    Inside: ls -l ; cat README.txt ; strings * | grep -i flag"
