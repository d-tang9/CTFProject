#!/usr/bin/env bash
set -euo pipefail

# ===== CONFIG =====
NAMESPACE="${NAMESPACE:-dtang9}"        # Docker Hub namespace
FILTER_PREFIX="${FILTER_PREFIX:-ctf}"  # Only repos starting with this prefix
PAGE_SIZE="${PAGE_SIZE:-100}"           # Adjust if you expect >100 repos
DEFAULT_TAG="${DEFAULT_TAG:-latest}"    # Tag to run

# ===== REQUIREMENTS =====
need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing required tool: $1"; exit 1; }; }
need curl
need docker

have_jq=false
if command -v jq >/dev/null 2>&1; then have_jq=true; fi

have_python=false
if command -v python3 >/dev/null 2>&1; then have_python=true; fi

# ===== UTIL =====
line() { printf '%*s\n' "${COLUMNS:-80}" '' | tr ' ' '-'; }

pause() { read -r -p "Press ENTER to continue... " _; }

fetch_page() {
  local url="$1"
  curl -fsSL "$url"
}

parse_names() {
  # Print repository names
  if $have_jq; then
    jq -r '.results[].name'
  elif $have_python; then
    python3 - "$@" <<'PY'
import sys, json
data=json.load(sys.stdin)
for r in data.get("results", []):
    name=r.get("name")
    if name: print(name)
PY
  else
    echo "This script needs either **jq** or **python3** to parse Docker Hub JSON." >&2
    exit 1
  fi
}

fetch_challenges() {
  local url="https://hub.docker.com/v2/repositories/${NAMESPACE}/?page_size=${PAGE_SIZE}"
  local names=()
  while :; do
    json="$(fetch_page "$url")"
    mapfile -t page_names < <(printf '%s' "$json" | parse_names)
    names+=("${page_names[@]}")
    # find "next" URL
    if $have_jq; then
      next=$(printf '%s' "$json" | jq -r '.next // empty')
    elif $have_python; then
      next=$(python3 - <<'PY'
import sys, json
d=json.load(sys.stdin)
print(d.get("next",""))
PY
        <<<"$json")
    else
      next=""
    fi
    [[ -n "${next:-}" ]] || break
    url="$next"
  done

  # Filter & sort
  printf '%s\n' "${names[@]}" | grep -E "^${FILTER_PREFIX}" | sort -V
}

print_menu() {
  echo "== Available Challenges from docker.io/${NAMESPACE} =="
  local i=1
  for n in "${CHALLENGES[@]}"; do
    printf "%2d) %s\n" "$i" "$n"
    ((i++))
  done
  line
  cat <<'TXT'
[A] Pull & Run by number
[R] Refresh list
[K] Kill ALL containers (stop & remove)
[L] List running containers
[Q] Quit
TXT
  line
}

run_challenge() {
  local repo="$1"
  local image="${NAMESPACE}/${repo}:${DEFAULT_TAG}"
  local cname="$repo"   # container name = repo name

  echo "Pulling ${image} ..."
  docker pull "${image}"

  # If container exists, ask what to do
  if docker ps -a --format '{{.Names}}' | grep -qx "$cname"; then
    echo "Container '${cname}' already exists."
    select act in "restart" "remove_and_run" "cancel"; do
      case "$act" in
        restart) docker start "$cname"; break;;
        remove_and_run) docker rm -f "$cname"; break;;
        cancel) echo "Canceled."; return;;
      esac
    done
  fi

  echo "Starting container: ${cname}"
  docker run -d --name "$cname" --security-opt no-new-privileges:true "$image" >/dev/null

  echo
  echo "${repo} is up. Here are useful commands:"
  cat <<EOF
  # See it running
  docker ps --filter name=${cname}

  # Stream logs
  docker logs -f ${cname}

  # Get a shell
  docker exec -it ${cname} /bin/bash    # or /bin/sh if bash isn't present

  # Stop & remove this container
  docker stop ${cname} && docker rm ${cname}

  # Restart it later
  docker restart ${cname}

  # Inspect details (ports, mounts, env)
  docker inspect ${cname} | less
EOF
  echo
}

kill_all() {
  echo "Stopping and removing ALL containers..."
  ids="$(docker ps -aq || true)"
  if [[ -z "$ids" ]]; then
    echo "No containers found."
    return
  fi
  docker stop $ids >/dev/null 2>&1 || true
  docker rm -f $ids >/dev/null 2>&1 || true
  echo "All containers removed."
}

list_running() {
  docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
}

# ===== MAIN LOOP =====
declare -a CHALLENGES
mapfile -t CHALLENGES < <(fetch_challenges)

while :; do
  clear || true
  print_menu

  read -r -p "Choose [number/A/R/K/L/Q]: " choice
  case "$choice" in
    # Direct number -> run that challenge
    ''|*[!0-9]*) 
      case "${choice^^}" in
        A)
          read -r -p "Enter the challenge number to run: " num ;;
        R)
          mapfile -t CHALLENGES < <(fetch_challenges); echo "List refreshed."; pause; continue ;;
        K)
          kill_all; pause; continue ;;
        L)
          list_running; pause; continue ;;
        Q)
          echo "Good luck!"; exit 0 ;;
        *)
          echo "Invalid choice."; pause; continue ;;
      esac
      ;;
    *)
      num="$choice"
      ;;
  esac

  # Validate selection
  if ! [[ "$num" =~ ^[0-9]+$ ]] || (( num < 1 || num > ${#CHALLENGES[@]} )); then
    echo "Invalid selection."; pause; continue
  fi

  repo="${CHALLENGES[$((num-1))]}"
  run_challenge "$repo"
  pause
done
