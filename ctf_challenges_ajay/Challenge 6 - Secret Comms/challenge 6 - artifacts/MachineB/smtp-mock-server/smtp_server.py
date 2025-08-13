#!/usr/bin/env python3
import ssl
import time
from aiosmtpd.controller import Controller

class PrintHandler:
    async def handle_DATA(self, server, session, envelope):
        print("=== New message ===")
        print("From:   ", envelope.mail_from)
        print("To:     ", envelope.rcpt_tos)
        print("Payload:")
        print(envelope.content.decode("utf8", errors="replace"))
        print("===================\n")
        # tell client we accepted it
        return '250 Message accepted for delivery'

if __name__ == "__main__":
    # Load your certificate + private key
    ssl_ctx = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH)
    ssl_ctx.load_cert_chain(certfile="cert.pem", keyfile="key.pem")
    ssl_ctx.keylog_filename="SSLKeys.log"

    # Implicit-TLS (SMTPS) on port 465
    controller = Controller(
        handler=PrintHandler(),
        hostname="192.168.10.130",
        port=465,
        ssl_context=ssl_ctx,
        data_size_limit=None
    )
    print("Starting SMTPS server…")
    controller.start()
    try:
        # keep the main thread alive
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        controller.stop()
        print("Server stopped.")
