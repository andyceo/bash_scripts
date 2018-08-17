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
MAX_CERT_AGE = 90  # maximum certificate age, days
THRESHOLD = 25  # minimum time before expiration alert, days


def check_certbot_dir(d, save_to_influxdb_flag: bool):
    t = time.time()
    file_threshold = SEC_IN_DAY * (MAX_CERT_AGE - THRESHOLD)
    for entry in os.scandir(d + '/live'):
        if not entry.name.startswith('.') and entry.is_dir():
            st_mtime = entry.stat().st_mtime
            age_file_check = t - st_mtime < file_threshold
            cert_expiration_timestamp = utils.get_cert_expiration_timestamp(entry.name)
            seconds_before_expiration = cert_expiration_timestamp - t
            age_cert_check = seconds_before_expiration > THRESHOLD * SEC_IN_DAY
            fields = {
                "age_file_check": age_file_check,
                "age_cert_check": age_cert_check,
                "check_result": age_file_check and age_cert_check,
                "st_mtime": st_mtime,
                "cert_expiration_timestamp": cert_expiration_timestamp,
                "seconds_before_expiration": round(seconds_before_expiration),
                "max_cert_age_days": MAX_CERT_AGE,
                "threshold_days": THRESHOLD
            }
            if save_to_influxdb_flag:
                save_to_influxdb(t, entry.name, fields)
            else:
                print_check_result(entry.name, fields)


def save_to_influxdb(timestamp, domain, fields):
    influxdb_password = utils.argparse_get_filezed_value(args, 'influxdb-password')
    try:
        json_body = [{
            "time": influxdb.timestamp_to_influxdb_format(timestamp),
            "measurement": "monitoring-certificate",
            "tags": {'domain': domain},
            "fields": fields
        }]
        client = influxdb.InfluxDBClient(args.influxdb_host, args.influxdb_port, args.influxdb_user,
                                         influxdb_password, args.influxdb_database)
        client.write_points(json_body)
        utils.message('Domain {} with check result {} was saved to InfluxDB on timestamp {}'
                      .format(domain, fields['check_result'], timestamp))
    except (influxdb.InfluxDBClientError, influxdb.InfluxDBServerError) as e:
        utils.message('Error saving domain {}, check result {} to InfluxDB on timestamp {}! Exception: {}'
                      .format(domain, fields['check_result'], timestamp, e))


def print_check_result(domain, fields):
    if 'check_result' in fields and fields['check_result']:
        print(color('[PASS] {}, file age check {}, cert age check {}, check result: {}'
                    .format(domain, fields['age_file_check'], fields['age_cert_check'], fields['check_result']),
                    fg='white', bg='green', style='bold'))
    else:
        print(color('[FAIL] {}, file age check {}, cert age check {}, check result: {}'
                    .format(domain, fields['age_file_check'], fields['age_cert_check'], fields['check_result']),
                    fg='white', bg='red', style='bold'))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Get Let's Encrypt (Certbot) SSL certificates expiration info")

    parser.add_argument('-p', '--path', metavar='PATH', default=os.environ.get(
        'CERTBOT_ETC_PATH', os.environ.get('LETSENCRYPT_ETC_PATH', '/etc/letsencrypt')),
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
            check_certbot_dir(args.path.rstrip(os.sep), True)
            sys.stdout.flush()
            time.sleep(int(args.interval))

    else:
        check_certbot_dir(args.path.rstrip(os.sep), args.save_to_influxdb)
