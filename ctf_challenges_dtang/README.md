This repo contains 10 challenges, each with a reproducible `build.sh`, a containerized environment,
and a `solve.sh` that validates the expected flag.

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
- `challenge name` — one folder per challenge with `build.sh`, `solve.sh`, `cleanup.sh`.
- `build_all.sh`, `solve_all.sh`, `validate_all.sh` — helper scripts.
