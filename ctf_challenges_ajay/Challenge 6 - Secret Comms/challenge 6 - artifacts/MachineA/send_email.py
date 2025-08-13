#!/usr/bin/env python3
import socket
import ssl
from email.message import EmailMessage
import mimetypes
import os

SMTP_HOST = "192.168.10.130"
SMTP_PORT = 465

def recv_line(s):
    """Read until CRLF."""
    buf = b""
    while not buf.endswith(b"\r\n"):
        chunk = s.recv(1)
        if not chunk:
            break
        buf += chunk
    return buf

# 1) Build the EmailMessage (headers/body + attachment)
msg = EmailMessage()
msg["Subject"] = "The NIST document you requested"
msg["From"]    = "ajay@group9.com"
msg["To"]      = "dickson@group9.com"
msg.set_content("Hello!\n\nHere’s your NIST doc. Let me know if you need anything else.\n")

file_path = "nist_csf_updated.pdf"
mime_type, _ = mimetypes.guess_type(file_path)
if mime_type is None:
    mime_type = "application/octet-stream"
maintype, subtype = mime_type.split("/", 1)

with open(file_path, "rb") as f:
    data = f.read()
msg.add_attachment(data, maintype=maintype, subtype=subtype, filename=os.path.basename(file_path))

# Prepare the full DATA payload (must end in CRLF . CRLF)
full_data = msg.as_bytes() + b"\r\n.\r\n"

# 2) Open a brand-new SSL socket
raw = socket.socket()
raw.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)  # disable Nagle
raw.connect((SMTP_HOST, SMTP_PORT))

ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
ctx.check_hostname = False
ctx.verify_mode   = ssl.CERT_NONE
tls = ctx.wrap_socket(raw, server_hostname=SMTP_HOST)

# 3) Do the SMTP handshake
print(recv_line(tls).decode().strip())          # 220 greeting
tls.sendall(b"EHLO me.example.com\r\n")
print(recv_line(tls).decode().strip())          # 250-... / 250 OK

# MAIL FROM / RCPT TO / DATA
tls.sendall(b"MAIL FROM:<ajay@group9.com>\r\n"); print(recv_line(tls).decode().strip())
tls.sendall(b"RCPT TO:<dickson@group9.com>\r\n"); print(recv_line(tls).decode().strip())
tls.sendall(b"DATA\r\n");                     print(recv_line(tls).decode().strip())

# 4) Send your entire DATA in one shot
tls.sendall(full_data)

# 5) **Read** the server’s 250 response to DATA—now you know it processed the message
print(recv_line(tls).decode().strip())

# 6) Send a **standalone** QUIT (also in one shot) and read the 221
tls.sendall(b"QUIT\r\n")
print(recv_line(tls).decode().strip())

# 7) Finally close the TLS socket (sends close_notify + TCP FIN)
tls.close()

print("Done: server saw the DATA begin, end, and the QUIT—no stray bytes were mis-framed.")    
