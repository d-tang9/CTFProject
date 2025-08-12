# Broken Backup Permissions (Challenge 4)

## Description
Find the backup script. The backups directory is locked from listing, but if you know the filename you can still read the leaked copy. Your goal is to find the script, understand the weakness, and read the flag from the backup.

# Solution
Step by step manual solution (player’s perspective):

1. Look for custom admin scripts that might handle backups:
   ```bash
   ls -l /usr/local/bin
   cat /usr/local/bin/backup.sh
   ```
2. Notice the risky line in the script (or similar):
   ```bash
   install -m 0644 /root/flag.txt /var/backups/flag_backup.txt
   ```
   This creates a world‑readable copy of the root‑only flag.
3. Check the directory permissions:
   ```bash
   ls -ld /var/backups   # typically shows 711: traversable but not listable
   ls /var/backups       # likely “Permission denied”
   ```
4. Read the leaked file directly using the known path:
   ```bash
   cat /var/backups/flag_backup.txt
   ```
   The file mode `0644` lets any user read it, so the flag prints.
5. If you didn’t spot the script right away, search for clues:
   ```bash
   grep -R --exclude-dir=/proc --exclude-dir=/sys -nE 'flag_backup|/var/backups|flag\.txt' / 2>/dev/null
   ```

# Recreating this challenge
High‑level steps (no build script required):

1. Create a workspace:
   ```bash
   mkdir -p challenge4/app
   ```
2. Add the flag (root‑only inside the image):
   ```text
   challenge4/flag.txt  ->  flag{broken_backup_permissions}
   ```
3. Create the vulnerable backup script at `challenge4/app/backup.sh`:
   ```bash
   #!/usr/bin/env bash
   set -euo pipefail
   mkdir -p /var/backups
   install -m 0644 /root/flag.txt /var/backups/flag_backup.txt
   ```
4. Write the Dockerfile at `challenge4/Dockerfile`:
   ```Dockerfile
   FROM ubuntu:22.04
   RUN useradd -m -s /bin/bash ctfuser
   COPY flag.txt /root/flag.txt
   RUN chmod 600 /root/flag.txt
   COPY app/backup.sh /usr/local/bin/backup.sh
   RUN chmod +x /usr/local/bin/backup.sh \
       && mkdir -p /var/backups \
       && /usr/local/bin/backup.sh \
       && chmod 711 /var/backups
   USER ctfuser
   WORKDIR /home/ctfuser
   CMD ["tail","-f","/dev/null"]   # keep container running for players
   ```
5. Build and run:
   ```bash
   docker build -t challenge4:latest challenge4
   docker run -d --name challenge4 challenge4:latest
   # player attaches:
   docker exec -it challenge4 bash -l
   ```
6. Manual validation inside the container:
   ```bash
   cat /var/backups/flag_backup.txt
   ```
