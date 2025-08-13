# Brute-Force Zip (Challenge 1)

## Description
A flag is hidden inside a password-protected ZIP file. You get a small wordlist. Your job is to try the passwords from the list until one opens the ZIP, then read the flag.

# Solution
1. Open the container shell and go to the home folder (usually `/home/ctfuser`).  
2. Read the breadcrumbs if present (`README.txt`, `NOTICE.txt`) to confirm there’s a `secret.zip` and a `wordlist.txt`.  
3. Try the passwords from the wordlist against the ZIP:
   ```bash
   while IFS= read -r pw; do
     if unzip -P "$pw" -o secret.zip >/dev/null 2>&1; then
       echo "Password found: $pw"
       break
     fi
   done < wordlist.txt
   ```
4. After a successful unzip, view the flag:
   ```bash
   cat flag.txt
   ```
   Expected format: `flag{bruteforce_zip}`.

# Recreating this challenge
1. Start from a minimal image (e.g., `alpine:3.20`). Install `bash`, `zip`, and `unzip`.  
2. Create a non-root user `ctfuser` and set `WORKDIR` to `/home/ctfuser`.  
3. Make `flag.txt` with the flag text (for example `flag{bruteforce_zip}`).  
4. Create `wordlist.txt` with a few decoy passwords and the real one (e.g., `lol123`).  
5. Zip the flag with the real password and remove the plaintext flag so only `secret.zip` remains.  
6. Add simple breadcrumbs (`README.txt`, `NOTICE.txt`) that hint to use the wordlist on `secret.zip`.  
7. Set the container to stay alive for manual solving (e.g., `CMD ["sleep","infinity"]`).  
8. Build and tag the image. The repo can include `build.sh`, `solve.sh`, and `cleanup.sh` for consistency and validation.
