#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from colors import color
from pylibs import influxdb
from pylibs import utils
import argparse
import tabulate


# @todo add show continuous queries, etc with SHOW {SOMETHING}
# @todo add ability to print separate sections and dynamically change lines_limit in print_points()


def influxdb_get_supscriptions(c, database: str):
    """
    Return subscriptions info from InfluxDB.
    :param c: InfluxDB client
    :param database: database on which query executes
    """
    rs = c.query('SHOW SUBSCRIPTIONS')
    return rs.get_points()


def influxdb_get_users(c):
    """
    Return users from InfluxDB.
    :param c: InfluxDB client
    """
    rs = c.query('SHOW USERS')
    return rs.get_points()


def influxdb_get_databases(c):
    """
    Return databases from InfluxDB.
    :param c: InfluxDB client
    """
    rs = c.query('SHOW DATABASES')
    return rs.get_points()


def influxdb_get_retention_policies(c):
    """
    Return retention policies from InfluxDB.
    :param c: InfluxDB client
    """
    rs = c.query('SHOW RETENTION POLICIES')
    return rs.get_points()


def influxdb_get_series(c, database: str):
    """
    Return series from InfluxDB.
    :param c: InfluxDB client
    :param database: database on which query executes
    """
    rs = c.query(add_on_clause('SHOW SERIES', database))
    return rs.get_points()


def influxdb_get_measurements(c, database: str):
    """
    Return measurements from InfluxDB.
    :param c: InfluxDB client
    :param database: database on which query executes
    """
    rs = c.query(add_on_clause('SHOW MEASUREMENTS', database))
    return rs.get_points()


def influxdb_get_tag_keys(c, database: str):
    """
    Return tag keys from InfluxDB.
    :param c: InfluxDB client
    :param database: database on which query executes
    """
    rs = c.query(add_on_clause('SHOW TAG KEYS', database))
    return rs.get_points()


def influxdb_get_tag_values(c, database: str, tag_keys):
    """
    Return tag values from InfluxDB.
    :param c: InfluxDB client
    :param database: database on which query executes
    :param tag_keys: tag keys iterable (list for example) or string
    """
    query = add_on_clause('SHOW TAG VALUES', database)
    try:
        tag_keys = [_['tagKey'] for _ in tag_keys]
        query += ' WITH KEY IN ("{}")'.format('", "'.join(tag_keys))
    except TypeError:
        query += ' WITH KEY {}'.format(tag_keys)
    rs = c.query(query)
    return rs.get_points()


def influxdb_get_field_keys(c, database: str):
    """
    Return field keys from InfluxDB.
    :param database: database on which query executes
    :param c: InfluxDB client
    """
    rs = c.query(add_on_clause('SHOW FIELD KEYS', database))
    return rs.get_points()


def add_on_clause(query: str, database: str) -> str:
    return '{} ON {}'.format(query, database)


def print_points(points):
    lines = tabulate.tabulate(points, headers="keys").splitlines()
    lines_limit = 25
    i = 1
    for line in lines:
        if i > lines_limit + 2:
            length = len(lines)
            # 2 lines is for header and line after header
            print('-----There is more {} lines (total {})-----'.format(length - lines_limit - 2, length - 2))
            break
        else:
            print(line)
            i += 1
    print()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Get InfluxDB server schema quick view '
                                                 '(global admin credentials required)')
    influxdb.argparse_add_influxdb_options(parser)
    args = parser.parse_args()
    influxdb_password = utils.argparse_get_filezed_value(args, 'influxdb-password')

    print('Connecting to InfluxDB with credentials HOST={}, PORT={}, USER={}, PASSWORD={}, DATABASE={}'.format(
        args.influxdb_host, args.influxdb_port, args.influxdb_user, influxdb_password, args.influxdb_database))
    print()

    client = influxdb.InfluxDBClient(args.influxdb_host, args.influxdb_port, args.influxdb_user, influxdb_password,
                                     args.influxdb_database)

    print(color('Users:', fg='white', bg='green', style='bold'))
    print_points(influxdb_get_users(client))

    print(color('Databases:', fg='white', bg='green', style='bold'))
    print_points(influxdb_get_databases(client))

    print(color('Retention Policies:', fg='white', bg='green', style='bold'))
    print_points(influxdb_get_retention_policies(client))

    print(color('Series:', fg='white', bg='green', style='bold'))
    print_points(influxdb_get_series(client, args.influxdb_database))

    print(color('Measurements:', fg='white', bg='green', style='bold'))
    print_points(influxdb_get_measurements(client, args.influxdb_database))

    print(color('Tag Keys:', fg='white', bg='green', style='bold'))
    tag_keys = [_ for _ in influxdb_get_tag_keys(client, args.influxdb_database)]
    print_points(tag_keys)

    print(color('Tag Values:', fg='white', bg='green', style='bold'))
    print_points(influxdb_get_tag_values(client, args.influxdb_database, tag_keys))

    print(color('Field Keys:', fg='white', bg='green', style='bold'))
    print_points(influxdb_get_field_keys(client, args.influxdb_database))

    print(color('Subscriptions:', fg='white', bg='green', style='bold'))
    print_points(influxdb_get_supscriptions(client, args.influxdb_database))
