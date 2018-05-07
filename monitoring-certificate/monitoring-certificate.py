#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from colors import color
from dateutil.parser import parse as parse_date
import argparse
import os
import ssl
import socket
import time

SEC_IN_DAY = 60 * 60 * 24  # number of seconds in a day
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
    parser = argparse.ArgumentParser(description='Get SSL certificates expiration info')

    parser.add_argument('-d', '--domains', nargs='+', metavar='example.com example.org', default=os.environ.get(
        'DOMAINS', ''), help='Domains to check certificates on. Use whitespace to separate domains. '
                             'Do not use schemes (http, https). If this option is not set, '
                             'DOMAINS environment variable is used')

    parser.add_argument('-p', '--path', nargs=1, metavar='/etc/letsencrypt', default=os.environ.get(
        'CERTBOT_ETC_PATH', os.environ.get('LETSENCRYPT_ETC_PATH', '/etc/letsencrypt')),
                        help='Path to certbot/letsencrypt certificate directory. If not passed, '
                             'CERTBOT_ETC_PATH or LETSENCRYPT_ETC_PATH environment variable are used '
                             '(CERTBOT_ETC_PATH take precedence), if none of them are present, '
                             '/etc/letsencrypt used as default')

    args = parser.parse_args()

    domains = {domain: False for domain in args.domains}  # we will set True for domain checked in filesystem loop

    t = time.time()
    file_threshold = SEC_IN_DAY * (MAX_CERT_AGE - THRESHOLD)
    for entry in os.scandir(args.path[0].rstrip(os.sep) + '/live'):
        if not entry.name.startswith('.') and entry.is_dir():
            age_file_check = t - entry.stat().st_mtime < file_threshold
            age_cert_check = get_cert_expiration(entry.name) - t > THRESHOLD

            if entry.name in domains:
                domains[entry.name] = True

            check_result = age_file_check and age_cert_check
            if check_result:
                print(color(' [PASS] {}, file age check {}, cert age check {}, result: {}'.format(
                    entry.name, age_file_check, age_cert_check,check_result), fg='white', bg='green', style='bold'))
            else:
                print(color(' [FAIL] {}, file age check {}, cert age check {}, result: {}'.format(
                    entry.name, age_file_check, age_cert_check,check_result), fg='white', bg='red', style='bold'))

    for domain in filter(lambda domain: not domains[domain], domains):
        age_cert_check = get_cert_expiration(domain) - t > THRESHOLD
        if age_cert_check:
            print(color(' [PASS] {}, file age check unavailable, cert age check {}, result: {}'.format(
                domain, age_cert_check, age_cert_check), fg='white', bg='green', style='bold'))
        else:
            print(color(' [FAIL] {}, file age check unavailable, cert age check {}, result: {}'.format(
                domain, age_cert_check, age_cert_check), fg='white', bg='red', style='bold'))
