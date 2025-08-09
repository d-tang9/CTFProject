# CTF Challenges 1–10 (Merged, Auto-Rebuild + Auto-Solve)

This repo contains 10 challenges, each with a reproducible `build.sh`, a containerized environment,
and a `solve.sh` that validates the expected flag. A global `docker-compose.yml` is included so your team
can start all challenge containers at once (for interactive exploration).

## Requirements
- Docker 24+
- Docker Compose v2
- Bash 5+

## Quick start (everything)
```bash
./build_all.sh        # builds all images
docker compose up -d  # (optional) starts one container per challenge
./solve_all.sh        # runs all solvers (they work with or without compose)
./validate_all.sh     # build + solve in one step
```

## Layout
- `challengeN/` — one folder per challenge with `build.sh`, `solve.sh`, `cleanup.sh`.
- `docker-compose.yml` — convenience to keep all containers running for demos.
- `build_all.sh`, `solve_all.sh`, `validate_all.sh` — orchestration helpers.
