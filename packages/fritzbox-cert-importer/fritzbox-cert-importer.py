#!/usr/bin/env python3
from os import environ, getenv
from time import sleep
from urllib.parse import urlencode
from urllib.request import Request, urlopen
import sys
import hashlib
import ssl
import xml.etree.ElementTree as ET

URL = environ["FRITZ_URL"] if getenv("FRITZ_URL") else "https://fritz.box"
USERNAME = environ["FRITZ_USERNAME"]
PASSWORD = environ["FRITZ_PASSWORD"]

ctx = ssl.create_default_context()
if getenv("FRITZ_INSECURE_TLS"):
    print("FRITZ_INSECURE_TLS set: Not verifying TLS certificates")
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE


def main():
    req = Request(url=f"{URL}/login_sid.lua?version=2", method="GET")
    with urlopen(req, context=ctx) as login_sid:
        xml = ET.fromstring(login_sid.read().decode("utf-8"))
        challenge = xml.find("Challenge").text
        blocktime = int(xml.find("BlockTime").text)

        challenge_response = calculate_pbkdf2_response(challenge, PASSWORD)

        if blocktime > 0:
            sleep(blocktime)

        req = Request(
            url=f"{URL}/login_sid.lua?version=2",
            method="POST",
            data=bytes(
                urlencode({"username": USERNAME, "response": challenge_response}),
                encoding="utf-8",
            ),
            headers={"Content-Type": "application/x-www-form-urlencoded"},
        )
        with urlopen(req, context=ctx) as post_sid:
            sid = ET.fromstring(post_sid.read().decode("utf-8")).find("SID").text
            with open(sys.argv[1], "r") as file:
                data = (
                    "------BoxCertBoundary\n"
                    'Content-Disposition: form-data; name="BoxCertImportFile"\n'
                    "Content-Type: application/octet-stream\n\n"
                    + file.read()
                    + "\n------BoxCertBoundary"
                )
                res = urlopen(
                    Request(
                        url=f"{URL}/cgi-bin/firmwarecfg",
                        method="POST",
                        headers={
                            "Content-Type": "multipart/form-data",
                            "Accept": "application/json",
                            "AUTHORIZATION": f"AVM-SID {sid}",
                        },
                        data=data.encode(),
                    ),
                    context=ctx,
                )
                print("Certificate imported")


def calculate_pbkdf2_response(challenge: str, password: str) -> str:
    challenge_parts = challenge.split("$")

    iter1 = int(challenge_parts[1])
    salt1 = bytes.fromhex(challenge_parts[2])
    iter2 = int(challenge_parts[3])
    salt2 = bytes.fromhex(challenge_parts[4])

    hash1 = hashlib.pbkdf2_hmac("sha256", password.encode(), salt1, iter1)
    hash2 = hashlib.pbkdf2_hmac("sha256", hash1, salt2, iter2)
    return f"{challenge_parts[4]}${hash2.hex()}"


if __name__ == "__main__":
    main()
