# Challenge 3 — Bashrc Backdoor

## Description
A malicious shell init snippet quietly copies a root-only flag to a world-readable file in `/tmp`. You run the container as a normal user (`ctfuser`). Your job is to find the clue, understand the backdoor, and retrieve the flag.

# Solution
1) **Explore the home directory.**  
   ```bash
   ls -la
   ```
   Look for something unusual. You should see a file named `root.bashrc`.

2) **Read the clue.**  
   ```bash
   cat root.bashrc
   ```
   This looks like a normal root `.bashrc`, but near the bottom there is a one‑liner that copies the flag:
   ```bash
   ( umask 022; cp /root/flag.txt /tmp/.cachefile 2>/dev/null || true; chmod 0644 /tmp/.cachefile 2>/dev/null || true )
   ```

3) **Follow what the code does.**  
   It copies `/root/flag.txt` to `/tmp/.cachefile` and makes it readable by everyone.

4) **Get the flag.**  
   ```bash
   ls -l /tmp/.cachefile
   cat /tmp/.cachefile
   ```
   You should see the flag printed.

# Recreating this challenge
High-level steps (no scripts needed here):
1) **Base image and user.** Use `ubuntu:22.04`. Create user `ctfuser` and set it as the default user. Disable root login (set shell to `nologin` and lock the password).
2) **Flag placement.** Copy `flag.txt` to `/root/flag.txt` and set permissions to `600`.
3) **Leak helper.** Add a root-owned helper at `/usr/local/bin/leak_once.sh` that runs:
   ```bash
   ( umask 022; cp /root/flag.txt /tmp/.cachefile; chmod 0644 /tmp/.cachefile )
   ```
4) **Tight sudo rule.** Install `sudo` and add `/etc/sudoers.d/ctfuser` with:
   ```
   ctfuser ALL=(root) NOPASSWD: /usr/local/bin/leak_once.sh
   ```
5) **Forensics clue.** Place a realistic `root.bashrc` in `/home/ctfuser/` that contains normal `.bashrc` content **plus** the malicious one‑liner above.
6) **Entrypoint.** Start as `ctfuser` and call the helper once:
   ```bash
   sudo /usr/local/bin/leak_once.sh
   ```
   Then keep a login shell alive (e.g., `bash -lc "sleep infinity"`).

**Result:** The flag is leaked to `/tmp/.cachefile`. Players can find `root.bashrc`, notice the backdoor line, and read the flag from `/tmp/.cachefile`.
