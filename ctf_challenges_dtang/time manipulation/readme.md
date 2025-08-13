# Time Manipulation (Challenge 7)

## Description
A Bash script checks its own integrity and only reveals the flag at a specific time. The script uses a checksum file to prevent tampering and relies on the `date` command to validate the unlock time. Players must find a way to bypass the time restriction without modifying the script.

## Solution
1. Read the `README.txt` in the home directory. It mentions that the unlock window is at exactly `04:00` and hints that `$HOME/bin` is placed before system paths.
2. Inspect `.bashrc` or `.bash_profile` to confirm that `$HOME/bin` is prepended to `PATH` and that this directory is created on login.
3. Create a custom script at `~/bin/date` that:
   - Outputs `04:00` when called with `+%H:%M`
   - Calls the real `/bin/date` for other arguments
4. Make the custom `date` script executable (`chmod +x ~/bin/date`).
5. Run `/opt/check_flag.sh`.  
   The integrity check passes since the script wasn’t modified, the time check passes due to the fake `date`, and the setuid helper prints the flag.

## Recreating this challenge
1. Create a working directory for the challenge with an `app` subdirectory.
2. Write `check_flag.sh` to:
   - Compute its own SHA-256 hash and compare it to a stored hash in `/opt/check_flag.sha256`
   - Compare `date +%H:%M` to the hardcoded unlock time (`04:00`)
   - Call a minimal setuid C program (`readflag`) to print the flag if checks pass
3. Create `flag.txt` in `/root/` with restrictive permissions so only root can read it.
4. Write `README.txt` with breadcrumbs about `$HOME/bin` and the unlock time.
5. Add `.bashrc` and `.bash_profile` to create `~/bin` and prepend it to `PATH`.
6. Write `readflag.c` that simply reads `/root/flag.txt` and prints it to stdout, then compile it and set the setuid bit.
7. Write a `Dockerfile` based on Alpine:
   - Install `bash`, `coreutils`, and `build-base`
   - Create user `ctfuser`
   - Copy all necessary files with correct ownership and permissions
   - Generate the checksum file after `check_flag.sh` is finalized
8. Build and run the container, ensuring it stays up for players to interact with.
