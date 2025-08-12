# Challenge 2 — Fragmented Flag Parser

## Description
Fifty text files sit in the CTF user’s home folder. Ten files contain fragments in the form `{fragmentN:X}`. Sort the fragments by `N` and join the characters `X` to get the 10‑character flag.

# Solution
1. Start a persistent container and open a shell.
   ```bash
   docker create --name challenge2-fragments challenge2-fragments:latest
   docker start challenge2-fragments
   docker exec -it challenge2-fragments bash
   ```
2. Go to the home folder and read the breadcrumb.
   ```bash
   cd ~
   cat README.txt
   ```
3. Find the fragments.
   ```bash
   grep -R "{fragment" .
   ```
4. Assemble the flag (one‑liner).
   ```bash
   grep -Rho -E '[{]fragment[0-9]+:[^}]+' . \
   | awk -F'[{}:]' '{n=$2; sub(/^fragment/,"",n); print n, $3}' \
   | sort -n \
   | awk '{printf "%s",$2}'
   ```
   The printed 10‑character string is the flag.

# Recreating this challenge
1. Pick a 10‑character flag (example: `fbujm38@db`).
2. Create 50 text files for the CTF user’s home (e.g., `file01.txt` … `file50.txt`) and fill them with harmless lines.
3. Choose 10 of those files and add exactly one line in each with the format `{fragmentN:X}` where `N=1..10` and `X` is the corresponding character of your flag.
4. Add a small `README.txt` in the home folder that tells players to look for `{fragmentN:X}` and assemble by sorting `N`.
5. Build an Alpine‑based image:
   - Install `bash`, `coreutils`, `grep`, and `findutils`.
   - Create a non‑root user `ctfuser` with shell `/bin/bash`.
   - Copy all 50 files (and `README.txt`) into `/home/ctfuser/`.
   - Set ownership to `ctfuser:ctfuser` and make the `.txt` files read‑only (e.g., `chmod 444`).
   - Set `USER ctfuser` and choose a CMD. For persistent play, `CMD ["sleep","infinity"]` is fine; players will attach with `docker exec`. For immediate shell, use `CMD ["bash"]`.
6. Publish the image with the tag `challenge2-fragments:latest` and instruct players to start and attach to a persistent container as shown in the Solution section.
