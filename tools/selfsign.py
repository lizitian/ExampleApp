#!/usr/bin/env python
import OpenSSL, sys
if __name__ == "__main__":
    with open(sys.argv[1], "rb") as f:
        key = OpenSSL.crypto.load_privatekey(OpenSSL.crypto.FILETYPE_PEM, f.read())
    cert = OpenSSL.crypto.X509()
    cert.set_version(2)
    cert.set_serial_number(0)
    cert.get_subject().CN = sys.argv[3]
    cert.set_notBefore(b"20000101000000Z")
    cert.set_notAfter(b"21000101000000Z")
    cert.set_issuer(cert.get_subject())
    cert.set_pubkey(key)
    cert.sign(key, "sha256")
    with open(sys.argv[2], "wb") as f:
        f.write(OpenSSL.crypto.dump_certificate(OpenSSL.crypto.FILETYPE_PEM, cert))
