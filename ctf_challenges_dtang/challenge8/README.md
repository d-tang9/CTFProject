# Reverse Engineering Binary (Challenge 8)

## Description
A compiled binary checks for a password and reveals the flag when the correct password is entered. The source code is not available to the player, requiring reverse engineering to find the password.

# Solution
1. Inside the container, locate the `checkpass` binary in the home directory.
2. Use the `strings` command to inspect the binary for human-readable text:  
   ```bash
   strings checkpass | grep "PWD="
   ```
3. Identify the password from the output (inside the `PWD=[...]` delimiters).
4. Run the binary and enter the extracted password:  
   ```bash
   ./checkpass
   Enter password: <password>
   ```
5. The binary will display the flag if the password is correct.

# Recreating this challenge
1. Write a small Go program (`checkpass.go`) that prompts the user for a password, compares it to the correct string, and prints the flag if it matches.
2. Embed a breadcrumb (e.g., `PWD=[<password>]`) in the code so that it appears in the compiled binary when inspected with `strings`.
3. Compile the program using:  
   ```bash
   go build -ldflags="-s -w" -o checkpass checkpass.go
   ```
4. Delete the source file to prevent players from accessing it.
5. Create a Dockerfile using `alpine:latest` as the base image. Install `bash` and `binutils` (for `strings`), create a non-root user, and copy the binary into their home directory.
6. Add a small README inside the container with minimal hints for the player.
7. Set the container to start in interactive mode with `bash` so players can explore the challenge environment.
