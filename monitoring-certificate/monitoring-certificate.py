#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from colors import color
from pylibs import influxdb
from pylibs import utils
import argparse
import os
import sys
import time

SEC_IN_DAY = 60 * 60 * 24  # number of seconds in a day
MAX_CERT_AGE = 90  # maximum certificate age in days
THRESHOLD = 25  # minimum time before expiration alert


def check_certbot_dir(d, save_to_influxdb_flag: bool):
    t = time.time()
    file_threshold = SEC_IN_DAY * (MAX_CERT_AGE - THRESHOLD)
    for entry in os.scandir(d + '/live'):
        if not entry.name.startswith('.') and entry.is_dir():
            age_file_check = t - entry.stat().st_mtime < file_threshold
            age_cert_check = utils.get_cert_expiration_timestamp(entry.name) - t > THRESHOLD
            check_result = age_file_check and age_cert_check

            if save_to_influxdb_flag:
                save_to_influxdb(t, entry.name, age_file_check, age_cert_check, check_result)
            else:
                print_check_result(entry.name, age_file_check, age_cert_check, check_result)


def save_to_influxdb(timestamp, domain, age_file_check: bool, age_cert_check: bool, check_result: bool):
    influxdb_password = utils.argparse_get_filezed_value(args, 'influxdb-password')
    try:
        json_body = [{
            "time": influxdb.timestamp_to_influxdb_format(timestamp),
            "measurement": "monitoring-certificate",
            "tags": {'domain': domain},
            "fields": {
                'age_file_check': age_file_check,
                'age_cert_check': age_cert_check,
                'check_result': check_result
            }
        }]
        client = influxdb.InfluxDBClient(args.influxdb_host, args.influxdb_port, args.influxdb_user,
                                         influxdb_password, args.influxdb_database)
        client.write_points(json_body)
        utils.message('Domain {}, file age check: {}, cert age_check: {}, check result {} was saved to InfluxDB on '
                      'timestamp {}'.format(domain, age_file_check, age_cert_check, check_result, timestamp))
    except BaseException:
        utils.message('Error saving domain {}, file age check: {}, cert age_check: {}, check result {} to InfluxDB on '
                      'timestamp {}!'.format(domain, age_file_check, age_cert_check, check_result, timestamp))


def print_check_result(domain, age_file_check: bool, age_cert_check: bool, check_result: bool):
    if check_result:
        print(color('[PASS] {}, file age check {}, cert age check {}, check result: {}'.format(
            domain, age_file_check, age_cert_check, check_result), fg='white', bg='green', style='bold'))
    else:
        print(color('[FAIL] {}, file age check {}, cert age check {}, check result: {}'.format(
            domain, age_file_check, age_cert_check, check_result), fg='white', bg='red', style='bold'))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Get Let's Encrypt (Certbot) SSL certificates expiration info")

    parser.add_argument('-p', '--path', nargs=1, metavar='PATH', default=os.environ.get(
        'CERTBOT_ETC_PATH', os.environ.get('LETSENCRYPT_ETC_PATH', ['/etc/letsencrypt'])),
                        help='Path to certbot/letsencrypt certificate directory. If not passed, '
                             'CERTBOT_ETC_PATH or LETSENCRYPT_ETC_PATH environment variable are used '
                             '(CERTBOT_ETC_PATH take precedence), if none of them are present, '
                             '/etc/letsencrypt used as default')

    utils.argparse_add_daemon_options(parser, SEC_IN_DAY)

    parser.add_argument('--save-to-influxdb', action='store_true', help='Save domains check results to influxdb '
                                                                        'or just output them to console')

    influxdb.argparse_add_influxdb_options(parser)

    args = parser.parse_args()

    if args.daemon:
        utils.message('monitoring-certificate daemon started.')
        while True:
            check_certbot_dir(args.path[0].rstrip(os.sep), args.save_to_influxdb)
            sys.stdout.flush()
            time.sleep(int(args.interval[0]))

    else:
        check_certbot_dir(args.path[0].rstrip(os.sep), args.save_to_influxdb)
