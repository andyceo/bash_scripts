# SSL Certificates (Let's Encrypt included) Monitoring Service

This is a dockerized script to monitor your SSL Let's Encrypt (Certbot) certificates expiration. Also you can monitor any domain certificate expiration date.


## Quick start

You must provide your Let's Encrypt (Certbot) data directory (usually `/etc/letsencrypt`), that store certificate data, from your host system to docker container with `-v` option, for automated domains discovery and certificate age check based on directory modification timestamp:

    sudo docker run --rm -v /etc/letsencrypt:/etc/letsencrypt:ro \
        -e INFLUXDB_HOST=localhost \
        -e INFLUXDB_PORT=8086 \
        -e INFLUXDB_USER=root \
        -e INFLUXDB_PASSWORD=yoursecret \
        -e INFLUXDB_DATABASE=monitoring \
        andyceo/monitoring-certificate

But you can provide only `--domains` option (or `DOMAINS` environment variable) and list domains you interested in:

    sudo docker run --rm -v /etc/letsencrypt:/etc/letsencrypt:ro \
        -e INFLUXDB_HOST=localhost \
        -e INFLUXDB_PORT=8086 \
        -e INFLUXDB_USER=root \
        -e INFLUXDB_PASSWORD=yoursecret \
        -e INFLUXDB_DATABASE=monitoring \
        andyceo/monitoring-certificate --domains example.com example.org --save-to-influxdb

Note that in case you used `--domains` option, you must provide option `--save-to-influxdb` explicitly to continue storing monitoring data to InfluxDB. If you did not do so, you can omit InfluxDB connection data and just see colored console output with domains expiration data check results:

    sudo docker run --rm -v /etc/letsencrypt:/etc/letsencrypt:ro andyceo/monitoring-certificate --domains example.com


## Configuration

To configure this script (or Docker service), use environment variables or corresponding script options:

- `DOMAINS`, `--domains`, `-d` (default is empty string): domains list to check certificate expiration in addition of domains that was autodiscovered in Let's Encrypt data directory
- `CERTBOT_ETC_PATH` , `--path`, `-p` (default is `/etc/letsencrypt`): path where Let's Encrypt (Cerbot) data is located
- `INFLUXDB_HOST`, `--influxdb-host` (default is `localhost`): InfluxDB server domain or IP
- `INFLUXDB_PORT`, `--influxdb-port` (default is `8086`): InfluxDB server listening port
- `INFLUXDB_USER`, `--influxdb-user` (default is `root`): InfluxDB user
- `INFLUXDB_PASSWORD`, `--influxdb-password` (default is empty string): InfluxDB user password
- `INFLUXDB_DATABASE`, `--influxdb-database` (default is empty string): InfluxDB database name


## Volumes

This script does not provide any volumes, but it is required to pass Let's Encrypt (Certbot) data directory from host system to container to be able to discover domains inside.

Provide:

- `-v /host/letsencrypt/data/dir:/etc/letsencrypt:ro` for host directory `/host/letsencrypt/data/dir` be passed to container at `/etc/letsencrypt` directory with read-only mode (recommended)
