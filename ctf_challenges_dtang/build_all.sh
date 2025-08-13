#!/usr/bin/env bash
set -euo pipefail

# ===== Settings you might change =====
DOCKER_USER="${DOCKER_USER:-dtang9}"
IS_PRIVATE="${IS_PRIVATE:-false}"     # "true" or "false"
ORDER_FILE="${ORDER_FILE:-challenges.order}"  # optional; lines: <folder name>
# =====================================

here="$(cd "$(dirname "$0")" && pwd)"

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing required tool: $1"; exit 1; }; }
need curl
need docker

# ===== Auth to Docker Hub =====
if [[ -z "${DOCKERHUB_TOKEN:-}" ]]; then
  echo "Set DOCKERHUB_TOKEN env var to your Docker Hub Personal Access Token." >&2
  exit 1
fi

# CLI login (for docker push)
echo "${DOCKERHUB_TOKEN}" | docker login --username "${DOCKER_USER}" --password-stdin >/dev/null 2>&1 || {
  echo "docker login failed for ${DOCKER_USER}. Check DOCKERHUB_TOKEN." >&2
  exit 1
}

# Confirm CLI identity
cli_user="$(docker info 2>/dev/null | awk -F': ' '/Username/ {print $2}')"
if [[ "${cli_user:-}" != "${DOCKER_USER}" ]]; then
  echo "Logged in as '${cli_user:-none}', expected '${DOCKER_USER}'." >&2
  exit 1
fi

# JWT for Hub API
HUB_JWT="$(
  curl -s -X POST https://hub.docker.com/v2/users/login/ \
    -H 'Content-Type: application/json' \
    -d "{\"username\":\"${DOCKER_USER}\",\"password\":\"${DOCKERHUB_TOKEN}\"}" \
  | awk -F'"' '/"token":/ {print $4}'
)"
[[ -n "${HUB_JWT}" ]] || { echo "Failed to get Docker Hub JWT." >&2; exit 1; }

# ===== Helpers =====
slugify() {
  # lower, replace non [a-z0-9._-] with '-', trim leading/trailing '-'
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9._-]+/-/g; s/^-+//; s/-+$//'
}

repo_exists() {
  local repo="$1"
  local code
  code="$(curl -s -o /dev/null -w '%{http_code}' \
    -H "Authorization: JWT ${HUB_JWT}" \
    "https://hub.docker.com/v2/repositories/${DOCKER_USER}/${repo}/")"
  [[ "$code" == "200" ]]
}

ensure_repo() {
  local repo="$1"; local desc="$2"
  if repo_exists "$repo"; then
    echo "Repo ${DOCKER_USER}/${repo} exists."
    return 0
  fi
  echo "Creating repo ${DOCKER_USER}/${repo} (private=${IS_PRIVATE})..."
  local payload="{\"namespace\":\"${DOCKER_USER}\",\"name\":\"${repo}\",\"is_private\":${IS_PRIVATE},\"description\":\"${desc}\"}"
  local code
  code="$(curl -s -o /dev/null -w '%{http_code}' \
    -X POST "https://hub.docker.com/v2/repositories/" \
    -H "Authorization: JWT ${HUB_JWT}" \
    -H "Content-Type: application/json" \
    -d "${payload}")"
  [[ "$code" == "201" ]] || { echo "Failed to create repo (HTTP ${code})." >&2; exit 1; }
}

discover_dirs() {
  # Use optional order file if present; otherwise, discover and sort.
  local -a out=()
  if [[ -f "${here}/${ORDER_FILE}" ]]; then
    while IFS= read -r line; do
      [[ -z "${line// }" ]] && continue
      [[ "${line:0:1}" == "#" ]] && continue
      [[ -d "${here}/${line}" && -f "${here}/${line}/build.sh" && -f "${here}/${line}/name.txt" ]] && out+=("$line")
    done < "${here}/${ORDER_FILE}"
  else
    while IFS= read -r -d '' d; do
      local base; base="$(basename "$d")"
      out+=("$base")
    done < <(find "$here" -mindepth 1 -maxdepth 1 -type d -print0 \
             | xargs -0 -I{} bash -c '[ -f "{}/build.sh" ] && [ -f "{}/name.txt" ] && printf "%s\0" "{}"')
    IFS=$'\n' out=($(printf "%s\n" "${out[@]}" | sort)); unset IFS
  fi
  printf "%s\n" "${out[@]}"
}

# ===== Main loop =====
mapfile -t CHALLENGE_DIRS < <(discover_dirs)

if [[ ${#CHALLENGE_DIRS[@]} -eq 0 ]]; then
  echo "No challenge folders found (need build.sh and name.txt in each folder)." >&2
  exit 1
fi

for dir in "${CHALLENGE_DIRS[@]}"; do
  challenge_dir="${here}/${dir}"

  # Read challenge name and derive identifiers
  chall_name_raw="$(sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' "${challenge_dir}/name.txt")"
  [[ -n "${chall_name_raw}" ]] || { echo "Empty name.txt in ${dir}" >&2; exit 1; }

  chall_slug="$(slugify "${chall_name_raw}")"
  local_tag="ctf-${chall_slug}:latest"
  repo_name="ctf-${chall_slug}"
  hub_tag="${DOCKER_USER}/${repo_name}:latest"

  echo ""
  echo "=============================="
  echo "Challenge: ${chall_name_raw}  (folder: ${dir})"
  echo "Slug:      ${chall_slug}"
  echo "Local tag: ${local_tag}"
  echo "Hub repo:  ${DOCKER_USER}/${repo_name}"
  echo "=============================="

  # Build: export vars so build.sh can tag correctly (recommended: use $IMAGE_TAG)
  export IMAGE_TAG="${local_tag}"
  export CHALLENGE_NAME="${chall_name_raw}"
  export CHALLENGE_SLUG="${chall_slug}"

  ( cd "${challenge_dir}" && chmod +x ./build.sh && ./build.sh )

  # Ensure local image exists (build.sh should have created $IMAGE_TAG)
  if ! docker image inspect "${local_tag}" >/dev/null 2>&1; then
    echo "ERROR: Expected image '${local_tag}' not found after build in '${dir}'." >&2
    echo "Hint: In ${dir}/build.sh, tag the build with:  docker build -t \"${IMAGE_TAG}\" .  (or use \$IMAGE_TAG)" >&2
    exit 1
  fi

  # Ensure repo on Hub
  ensure_repo "${repo_name}" "CTF challenge: ${chall_name_raw}"

  # Tag and push
  echo "Tagging: ${local_tag} -> ${hub_tag}"
  docker tag "${local_tag}" "${hub_tag}"

  echo "Pushing: ${hub_tag}"
  if ! docker push "${hub_tag}"; then
    echo "Push failed; refreshing login and retrying once..."
    echo "${DOCKERHUB_TOKEN}" | docker login --username "${DOCKER_USER}" --password-stdin >/dev/null 2>&1
    docker push "${hub_tag}"
  fi
done

echo ""
echo "All images built and pushed to Docker Hub."
