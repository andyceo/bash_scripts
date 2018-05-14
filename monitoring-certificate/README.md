# SSL Certificates (Let's Encrypt included) Monitoring Service

This is a dockerized script to monitor your SSL Let's Encrypt (Certbot) certificates expiration.


## Quick start

You must provide your Let's Encrypt (Certbot) data directory (usually `/etc/letsencrypt`), that store certificate data, from your host system to docker container with `-v` option, for automated domains discovery and certificate age check based on directory modification timestamp:

    docker run --rm -v /etc/letsencrypt:/etc/letsencrypt:ro andyceo/monitoring-certificate

The command above show you colorized domains expiration data check results.

Use `-h` option to view help message:

    docker run --rm -v /etc/letsencrypt:/etc/letsencrypt:ro andyceo/monitoring-certificate -h

You can add InfluxDB connection data and save data to provided database in `monitoring-certificate` measurement with simple log output instead colorized output:

    docker run --rm -v /etc/letsencrypt:/etc/letsencrypt:ro \
        -e INFLUXDB_HOST=localhost \
        -e INFLUXDB_PORT=8086 \
        -e INFLUXDB_USER=root \
        -e INFLUXDB_PASSWORD=yoursecret \
        -e INFLUXDB_DATABASE=monitoring \
        andyceo/monitoring-certificate --save-to-influxdb

Daemon mode `--daemon` always make saving data to InfluxDB. Use this mode if you want to create dockerized certificates monitoring service:

    docker run -d -v /etc/letsencrypt:/etc/letsencrypt:ro \
        -e INFLUXDB_HOST=localhost \
        -e INFLUXDB_PORT=8086 \
        -e INFLUXDB_USER=root \
        -e INFLUXDB_PASSWORD=yoursecret \
        -e INFLUXDB_DATABASE=monitoring \
        andyceo/monitoring-certificate --daemon


## Configuration

To configure this script (or Docker service), use environment variables and/or corresponding script arguments:

- `CERTBOT_ETC_PATH` , `--path`, `-p` (default is `/etc/letsencrypt`): path where Let's Encrypt (Cerbot) data is located
- `INFLUXDB_HOST`, `--influxdb-host` (default is `localhost`): InfluxDB server domain or IP
- `INFLUXDB_PORT`, `--influxdb-port` (default is `8086`): InfluxDB server listening port
- `INFLUXDB_USER`, `--influxdb-user` (default is `root`): InfluxDB user
- `INFLUXDB_PASSWORD`, `--influxdb-password` (default is empty string): InfluxDB user password
- `INFLUXDB_DATABASE`, `--influxdb-database` (default is empty string): InfluxDB database name


## Volumes

This script does not provide any volumes, but it is required to pass Let's Encrypt (Certbot) data directory from host system to container to discover domains inside Let's Encrypt (Cerbot) data directory.

Provide:

- `-v /host/letsencrypt/data/dir:/etc/letsencrypt:ro` for host directory `/host/letsencrypt/data/dir` be passed to container at `/etc/letsencrypt` directory with read-only mode (recommended)
