# Hidden in Plain Sight

## Description
A binary file with a random hex-looking name hides the flag deep inside its data at a fixed offset. Players must use basic forensic techniques to extract the hidden string.

# Solution
1. List files in the home directory using `ls -la`. Notice the strange hex-looking filename.
2. Open `README.txt` for hints suggesting hex names and use of `strings` or `hexdump`.
3. Run `strings <hex_filename> | grep -i flag` to search for the flag pattern in the binary file.
4. Once the flag appears in the output, copy it to submit.

# Recreating this challenge
1. Create a working directory `challenge6` and an `app` subdirectory.
2. Generate 1 KiB of random data: `dd if=/dev/urandom of=random.bin bs=1024 count=1`.
3. Embed the flag at a fixed offset (e.g., byte 500) using: `printf 'flag{hidden_in_plain_sight}' | dd of=random.bin bs=1 seek=500 conv=notrunc`.
4. Rename the binary to the hex encoding of a filename (e.g., `note_flag.txt` → `6e6f74655f666c61672e747874`).
5. Create breadcrumb files like `README.txt` and `/var/log/app/rename.log` to hint at hex names and binary analysis.
6. Write a `Dockerfile` based on `alpine:latest` (with Bash installed), create a `ctfuser` account, copy the obfuscated binary and breadcrumbs into `/home/ctfuser`, and set the container to remain running for manual exploration.
