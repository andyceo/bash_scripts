#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from dateutil.parser import parse as parse_date
import os
import ssl
import socket
import time

SEC_IN_DAY = 60 * 60 * 24  # number of seconds in a day
CERTBOT_ETC_PATH = os.environ.get('CERTBOT_ETC_PATH', '/etc/letsencrypt')
MAX_CERT_AGE = 90  # maximum certificate age in days
THRESHOLD = 25  # minimum time before expiration alert


def get_cert_expiration(url):
    try:
        ctx = ssl.create_default_context()
        s = ctx.wrap_socket(socket.socket(), server_hostname=url)
        s.connect((url, 443))
        cert = s.getpeercert()
        return round(time.mktime(parse_date(cert['notAfter']).timetuple()))
    except ssl.SSLError:
        return 0


if __name__ == "__main__":
    t = time.time()
    file_threshold = SEC_IN_DAY * (MAX_CERT_AGE - THRESHOLD)
    for entry in os.scandir(CERTBOT_ETC_PATH + '/live'):
        if not entry.name.startswith('.') and entry.is_dir():
            age_file_check = t - entry.stat().st_mtime < file_threshold
            age_cert_check = get_cert_expiration(entry.name) - t > THRESHOLD
            print('{}, file age check {}, cert age check {}'.format(entry.name, age_file_check, age_cert_check))
