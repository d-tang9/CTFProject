#!/usr/bin/env bash
set -euo pipefail

# --- CONFIG ---
DOCKER_USER="dtang9"                    # Your Docker Hub username
IS_PRIVATE="${IS_PRIVATE:-false}"       # Set IS_PRIVATE=true to create private repos
START="${START:-1}"                     # Optional: set START/END to limit which to build
END="${END:-10}"

here="$(cd "$(dirname "$0")" && pwd)"

# --- REQUIREMENTS CHECK ---
for bin in curl docker; do
  command -v "$bin" >/dev/null || { echo "Missing required tool: $bin"; exit 1; }
done

# --- AUTH FOR DOCKER HUB API (uses Personal Access Token as password) ---
# Provide via env var DOCKERHUB_TOKEN or get prompted once.
if [[ -z "${DOCKERHUB_TOKEN:-}" ]]; then
  read -r -s -p "Enter Docker Hub Personal Access Token for ${DOCKER_USER}: " DOCKERHUB_TOKEN
  echo
fi

# Get a short-lived JWT for API calls
HUB_JWT="$(curl -s -X POST https://hub.docker.com/v2/users/login/ \
  -H 'Content-Type: application/json' \
  -d "{\"username\":\"${DOCKER_USER}\",\"password\":\"${DOCKERHUB_TOKEN}\"}" \
  | awk -F'"' '/"token":/ {print $4}')"

if [[ -z "${HUB_JWT}" ]]; then
  echo "Failed to get Docker Hub JWT. Check username/token (and 2FA requires a PAT)."
  exit 1
fi

# --- OPTIONAL: verify docker CLI login matches username (for pushing) ---
cli_user="$(docker info 2>/dev/null | awk -F': ' '/Username/ {print $2}')"
if [[ "${cli_user:-}" != "${DOCKER_USER}" ]]; then
  echo "Warning: docker CLI not logged in as ${DOCKER_USER} (current: ${cli_user:-none})."
  echo "Run: docker login --username ${DOCKER_USER}   (use the same PAT if you have 2FA)"
fi

# --- HELPERS ---
slugify() {
  # lowercase, spaces->-, strip invalid chars for repo name
  echo "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9._-]+/-/g; s/^-+//; s/-+$//'
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
  local repo="$1"
  local desc="$2"
  if repo_exists "$repo"; then
    echo "Repo ${DOCKER_USER}/${repo} exists."
    return 0
  fi
  echo "Creating repo ${DOCKER_USER}/${repo} (private=${IS_PRIVATE})..."
  local payload
  payload="$(jq -cn --arg ns "$DOCKER_USER" --arg name "$repo" \
                  --argjson priv "$( [[ "$IS_PRIVATE" == "true" ]] && echo true || echo false )" \
                  --arg desc "$desc" \
                  '{namespace:$ns,name:$name,is_private:$priv,description:$desc}')"
  # If jq isn't installed, build JSON without jq as a fallback
  if [[ -z "${payload}" ]]; then
    payload="{\"namespace\":\"${DOCKER_USER}\",\"name\":\"${repo}\",\"is_private\":${IS_PRIVATE},\"description\":\"${desc}\"}"
  fi

  local code
  code="$(curl -s -o /dev/null -w '%{http_code}' \
    -X POST "https://hub.docker.com/v2/repositories/" \
    -H "Authorization: JWT ${HUB_JWT}" \
    -H "Content-Type: application/json" \
    -d "${payload}")"
  if [[ "$code" != "201" ]]; then
    echo "Failed to create repo (HTTP $code)."
    exit 1
  fi
}

# --- MAIN LOOP ---
for d in $(seq "$START" "$END"); do
  challenge_dir="$here/challenge$d"
  [[ -d "$challenge_dir" ]] || { echo "Skip: ${challenge_dir} (missing)"; continue; }

  echo "== Building challenge $d =="
  (cd "$challenge_dir" && ./build.sh)

  # Get human name from name.txt (required). Example: "Brute Force Zip"
  if [[ -f "$challenge_dir/name.txt" ]]; then
    chall_name_raw="$(sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' "$challenge_dir/name.txt")"
  else
    echo "Error: ${challenge_dir}/name.txt not found (put the challenge name there)."
    exit 1
  fi

  chall_name="$(slugify "$chall_name_raw")"
  repo_name="challenge${d}-${chall_name}"
  local_tag="challenge${d}:latest"
  hub_tag="${DOCKER_USER}/${repo_name}:latest"

  # Make sure repo exists (create if not)
  ensure_repo "$repo_name" "CTF challenge ${d}: ${chall_name_raw}"

  echo "== Tagging image: ${local_tag} → ${hub_tag} =="
  docker tag "${local_tag}" "${hub_tag}"

  echo "== Pushing ${hub_tag} to Docker Hub =="
  docker push "${hub_tag}"
done

echo "All images built and pushed to Docker Hub."
