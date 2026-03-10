#!/usr/bin/env python3
from os import environ, getenv
from time import sleep
from urllib.parse import urlencode
from urllib.request import Request, urlopen
import hashlib
import ssl
import xml.etree.ElementTree as ET

URL = environ["FRITZ_URL"] if getenv("FRITZ_URL") else "https://fritz.box"
USERNAME = environ["FRITZ_USERNAME"]
PASSWORD = environ["FRITZ_PASSWORD"]

ctx = ssl.create_default_context()
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
            urlopen(
                Request(
                    url=f"{URL}/api/v0/generic/landevice",
                    method="PUT",
                    data=bytes('{"cleanup_landevices":"1"}', encoding="utf-8"),
                    headers={
                        "Content-Type": "application/json",
                        "AUTHORIZATION": f"AVM-SID {sid}",
                    },
                ),
                context=ctx,
            )
            print("LAN devices cleaned up")


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
