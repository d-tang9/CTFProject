

# Challenge 2 Picture Picture

## Description

The objective of this challenge is to extract an image containing the flag from the provided packet capture.

# Solution
**1. Analyzing the PCAP**

Filter on HTTP traffic using the filter 'http' and notice that there are two packets.

    No	Time		Source			Destination		Protocol			Length		Info
    436	17.285631	192.168.10.136	192.168.10.128	HTTP				276			GET /15-i-have-no-idea.jpg HTTP/1.1 
    528	17.286620	192.168.10.128	192.168.10.136	HTTP				337			HTTP/1.1 200 OK  (JPEG JFIF image)

The first packet is a GET request for a image file and the second packet is the response containing the file. Extracting the '15-i-have-no-idea.jpg' file does not provide any meaningful information. Participants may believe that this contains a hidden message using stenography which isn't the case. 

 
**2. Inspect the TCP stream of the GET request**

When inspecting the TCP of the GET request which is 'tcp.stream eq 5' notice the unusually large cookie. This cookie appears to be a base64 payload. 

    GET /15-i-have-no-idea.jpg HTTP/1.1
    Host: 192.168.10.128:8080
    User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:135.0) Gecko/20100101 Firefox/135.0
    Accept-Encoding: gzip, deflate
    Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.:8
    Connection: keep-alive
    Accept-Language: en-US,en;q=0.5
    Referer: http://192.168.10.128:8080/
    Upgrade-Insecure-Requests: 1
    Priority: u=0, i
    cookies: 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Su5GjKDIbrXe21vFaQQ28K7IoY0ijXJbaiKFUZYljgADJJPrQAAcLY+EJF1CHUNV1OfV5rfm2DxrDDC398RK8g3dCCMcqCckCvQqAADkdf8ADNtrrQT+bNZ3dt/qLyA4kTnOD03LnkDIIbODya66gAA8x/4Qm4vpoW1rWrnVYYWDpb+StvExH/PTbI+70J4bHGa9OoAAE6Vxl54K8Oahcy3VzY+ZNM2+R/Pul3Me+1Z1UfgBQAAdpXn/APwr7wp/0Df/ACZvP/kigAA2fEmgR+IrAWrzPbskqTxSoMlJEDAErlcjDHjcPrV/StH0/RIHgsIfIieQysu+STLlVUnMru3RVG3OOKAADmL3wvealplnZ3mqG4lt71Lr7SbVVMioHAiMazAD7/39x6dK7+gAAz9StP7QsLu03+X9pt5oN+3d5fmxsm7blc4znGRn1rQoAAPPpvCHm+F49B+27dm3/SfIznExl/1Xne+P9Z716DQAAcTq3hSDVILHFzNa3dgiCC8g+VxhQCGGeVOMgbgQeh2k57agAA8zHgy6vJoG1nWrnVYYHEiW/kpbxM6/dMgV339x2OCRmvTKAAArhp/Anhi4lkmk0/c8rmR2+03YyzHJOBOAMk9AMUAAHc15/wD8K+8Kf9A3/wAmrz/5JoAANrX/AA7Z+III0mMkMsLb7e4iO2WF+OVPocDI9gQQRmtTTdNtNItVtLOLyYkJKpvd8Fjk8yMzck+tAABwEngq+v8AZFqviC8v7VGDfZxCsG/b08yQSOW+pGe4INeo0AAHG674WtdZt7OOOWSxlsSDZzQdYcBRjbkZUbFxhlIKjBrsqAADy+fwTd6jC8Wq67eX67HEKiJYIUkKkJK8aSHzTGTuALLnoTivUKAADgpPB9tc6FZ6Vc3Du9nzBdxL5MkbgnayqXkwMEBhu5xkYOMd7QAAeXyeDNRvkW31LxFeXlplS0CwpC0gU5AeXe5bnHUHnng16hQAAZF1LpmnWfk3Mlvb26wmPZI6ovkqu0qATkgLxgZNQaroGl64YDqFsLjyCxiy8qbd+3d/q3XcDsXIbI4oAAOB+Gmkpa6bcX5Vgb2UiHf98W0JKpn0LNuzjggKa9YjjSFFjjVURFCqqgKqqBgAAcBQOgFAABz+q6Veahd6bPBqU9klnN5k0Me/beLvjby5Ns0YxhGX5kcYc8V0lAAAUUAAHNaJpN5pf2v7TqU+o/aJfMj87f8AuF5/drvml457bRx0rpaAADm/EGlXesWaQWmpT6W6zLIZoN+5lCOpjOyaE4JYN94jIHFdJQAAcT43kSPwzqRdgN0QQZ7sWUAD3Na+o+H9J1a4huL20SeSAYQu0m0DOcGMOI3GezqaAACTQYzFoulxnOUsrRTkYOVhQcjt9K26AAAooAACigAAKKAAAooAACigAAKKAAAooAACigAAKKAAAooAACigAAKKAAAooAACigAAKKAAAooAACigAAKKAAAooAACigAAKKAAAooAACigAAKKAAAooAACigAAKKAAAooAACigAAKKAAAooAACigAAKKAAAooAACigAAKKAAAooAACigAAKKAAAooAACigAAKKAAAooAACigAAKKAAAooAACigAAKKAAAooAACigAAKKAAAooAACigAAKKAAAooAACigAAKKAAAooAACigAAKKAAAooAACigAAKKAAAooAACigAAKKAAAooAACigAAKKAAAooAACigAAKKAAAooAACigAAKKAAAooAACigAAKKAAAooAACigAA/9k=
    
    HTTP/1.1 200 OK
    Date: Thu, 05 Jun 2025 19:42:12 GMT
    Server: Apache/2.4.63 (Unix)
    Last-Modified: Thu, 05 Jun 2025 19:10:09 GMT
    ETag: "10f6f-636d7dcbae84e"
    Accept-Ranges: bytes
    Content-Length: 69487
    Keep-Alive: timeout=5, max=100
    Connection: Keep-Alive
    Content-Type: image/jpeg

**3. Decode this payload**
 
Decode the payload using any method that you prefer. It is encouraged to explore tools such as Cyberchef 'https://gchq.github.io/CyberChef/' which makes this decoding process simple. 

First copy the contents of the 'cookie' header into the input section of cyberchef.
Second use the 'From Base64 module'

Notice how in decoded output section, the following JPEG header is now visible

    ÿØÿà␀␐JFIF␀␁␁␀␀␁␀␁␀␀ÿÛ␀C␀␈ 

Download the output using the "Save to file" option within Cyberchef. 

**4. Analyze downloaded output.**
 
The encoded file is actually a image containing the flag which is:

    Flag{do_you_think_it_would_be_this_easy!?!}

The challenge is solved!


# Recreating this challenge 
Recreating this challenge is simple however requires a few steps.

**1. Prepare image containing the flag**

Use any photo editing application to create a small image containing the flag string. For this challenge, MS Paint was utilized. 

**2. On MachineA run the Docker Compose script to start the Apache webserver** 

In the directory 'challenge 2 - artifacts/MachineA/apache-server' contains a docker compose file to run a Apache webserver which will be used to send the request too. Within the 'httpd.conf' file is its modified configuration to allow for large headers within requests as this is typically not allowed. The 'public_html' contains the arbitrary image used as a decoy. Feel free to replace the file as required. 

Run the Apache server using docker compose 

     docker compose up
    [+] Running 7/7
     ✔ apache Pulled                                                           8.0s 
       ✔ 59e22667830b Already exists                                           0.0s 
       ✔ c02ce4e0ebb3 Pull complete                                            0.3s 
       ✔ 4f4fb700ef54 Pull complete                                            0.3s 
       ✔ fc61fad0f540 Pull complete                                            3.7s 
       ✔ e7b83145b209 Pull complete                                            7.3s 
       ✔ 644bfd3d7e68 Pull complete                                            7.3s 
    [+] Running 2/2
     ✔ Network apache-server_default      C...                                 0.1s 
     ✔ Container apache-directory-server  Created                              0.1s 
    Attaching to apache-directory-server
    apache-directory-server  | AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 172.22.0.2. Set the 'ServerName' directive globally to suppress this message

**3. Modify the 'image_request.py' script** 

Modify the 'image_request.py' script provided in 'challenge 2 - artifacts/MachineA/' folder to include the correct IP address of machineA as shown below:

    from scapy.all import IP, ICMP, send
    import textwrap, base64, time, requests

    # replace 'image.jpg' with the name of the image containing the flag. 
    with open("image.jpg", "rb") as f:
    	img = base64.b64encode(f.read()).decode()
    
    headers = {
    	"User-Agent": "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:135.0) Gecko/20100101 Firefox/135.0",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.:8",
        "Accept-Language": "en-US,en;q=0.5",
        "Accept-Encoding": "gzip, deflate",
        "Connection": "keep-alive",
        "Referer": "http://192.168.10.128:8080/", # Replace with IP address of Machine A
        "Upgrade-Insecure-Requests": "1",
        "Priority": "u=0, i",
        "cookies": img
    }
    
    # Replace '192.168.10.128' with IP address of machineA
    # Update URL path to file name of the arbitrary image if the image has been changed
    response = requests.get("http://192.168.10.128:8080/15-i-have-no-idea.jpg", headers=headers)

**4. Begin network capture using Wireshark. This requires two machines, machineA and machineB.**

(optional step) to create arbitrary network traffic run tool 'noisy' https://github.com/1tayH/noisy. Be sure to modify the configuration file to remove unwanted URLs. 

**5. Execute script on 'image_requst.py' MachineA**

Execute the 'image_request.py' script ensuring that the image containing the flag is in the same directory. 

    └─$ ls
    image.jpg  post_image.py
                                                                                                                                                                                                         
    ┌──(kali㉿kali)
    └─$ python3 post_image.py

**6. Confirm that the HTTP packet request and response were captured**

Prior to saving the packet capture, verify that the HTTP request and response were captured and that the 'cookie' header contains the base64 encoded image data. 

**7. Stop and save packet capture.** 

This completes the recreation of this CTF Challenge. 
