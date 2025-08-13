#!/usr/bin/env bash
set -euo pipefail

DOCKER_USER="dtang9"
IS_PRIVATE="${IS_PRIVATE:-false}"
START="${START:-1}"
END="${END:-10}"

here="$(cd "$(dirname "$0")" && pwd)"

need() { command -v "$1" >/dev/null || { echo "Missing required tool: $1"; exit 1; }; }
need curl
need docker

# ---- Docker Hub API auth (PAT required if 2FA) ----
if [[ -z "${DOCKERHUB_TOKEN:-}" ]]; then
  echo "Set DOCKERHUB_TOKEN env var to your Docker Hub Personal Access Token."
  exit 1
fi

# Log in the docker CLI non-interactively so push has rights
echo "${DOCKERHUB_TOKEN}" | docker login --username "${DOCKER_USER}" --password-stdin >/dev/null 2>&1 || {
  echo "docker login failed for ${DOCKER_USER}. Check DOCKERHUB_TOKEN."
  exit 1
}

# Verify CLI username
cli_user="$(docker info 2>/dev/null | awk -F': ' '/Username/ {print $2}')"
if [[ "${cli_user:-}" != "${DOCKER_USER}" ]]; then
  echo "Logged in as '${cli_user:-none}', expected '${DOCKER_USER}'."
  exit 1
fi

# Get JWT for Hub API
HUB_JWT="$(curl -s -X POST https://hub.docker.com/v2/users/login/ \
  -H 'Content-Type: application/json' \
  -d "{\"username\":\"${DOCKER_USER}\",\"password\":\"${DOCKERHUB_TOKEN}\"}" \
  | awk -F'"' '/"token":/ {print $4}')"
[[ -n "${HUB_JWT}" ]] || { echo "Failed to get Docker Hub JWT."; exit 1; }

slugify() {
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
  [[ "$code" == "201" ]] || { echo "Failed to create repo (HTTP ${code})."; exit 1; }
}

# --- Build, tag, push ---
for d in $(seq "$START" "$END"); do
  challenge_dir="$here/challenge$d"
  [[ -d "$challenge_dir" ]] || { echo "Skip: ${challenge_dir} (missing)"; continue; }

  echo "== Building challenge $d =="
  (cd "$challenge_dir" && ./build.sh)

  # Challenge name comes from name.txt
  [[ -f "$challenge_dir/name.txt" ]] || { echo "Missing ${challenge_dir}/name.txt"; exit 1; }
  chall_name_raw="$(sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' "$challenge_dir/name.txt")"
  chall_name="$(slugify "$chall_name_raw")"

  repo_name="challenge${d}-${chall_name}"
  local_tag="challenge${d}:latest"
  hub_tag="${DOCKER_USER}/${repo_name}:latest"

  ensure_repo "$repo_name" "CTF challenge ${d}: ${chall_name_raw}"

  echo "== Tagging image: ${local_tag} → ${hub_tag} =="
  docker image inspect "${local_tag}" >/dev/null 2>&1 || { echo "Local image ${local_tag} not found"; exit 1; }
  docker tag "${local_tag}" "${hub_tag}"

  echo "== Pushing ${hub_tag} to Docker Hub =="
  if ! docker push "${hub_tag}"; then
    echo "Push failed; refreshing login and retrying once..."
    echo "${DOCKERHUB_TOKEN}" | docker login --username "${DOCKER_USER}" --password-stdin >/dev/null 2>&1
    docker push "${hub_tag}"
  fi
done

echo "All images built and pushed to Docker Hub."
