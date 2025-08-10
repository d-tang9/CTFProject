#!/usr/bin/env bash
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
DOCKER_USER="dtang9"

for d in $(seq 1 10); do
  echo "== Building challenge $d =="

  # Build the local image
  (cd "$here/challenge$d" && ./build.sh)

  # Get challenge name (replace with your own method if needed)
  if [[ -f "$here/challenge$d/name.txt" ]]; then
    chall_name=$(cat "$here/challenge$d/name.txt" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
  else
    echo "Error: name.txt not found in challenge$d"
    exit 1
  fi

  local_tag="challenge${d}:latest"
  hub_tag="${DOCKER_USER}/challenge${d}-${chall_name}:latest"

  echo "== Tagging image: ${local_tag} → ${hub_tag} =="
  docker tag "${local_tag}" "${hub_tag}"

  echo "== Pushing ${hub_tag} to Docker Hub =="
  docker push "${hub_tag}"
done

echo "All images built and pushed to Docker Hub."
