# Mongo Backup Service

This is a docker service to backup data Mongo directory to specific remote host directory, or mounted local directory.


## Quick start

    sudo docker run -d --net=docknet -e MONGO_HOST=mongo -e MONGO_ADMIN_PASSWORD="123qwe" \
        -v /data/mongo/data:/data/db:ro
        -v /backup/mongo:/backup/mongo
        andyceo/mongo-backup


## Configuration

To configure this service, use environment variables,

- `MONGO_HOST` (default is "localhost"): Mongo server domain or IP
- `MONGO_PORT` (default is "27017"): Mongo server listening port
- `MONGO_AUTHENTICATION_DATABASE`: Database to read user credentials from
- `MONGO_ADMIN_USERNAME` (default is "root"): Mongo server administrator name
- `MONGO_ADMIN_PASSWORD_FILE` (default is "/run/secrets/root-at-mongo"): File that stores Mongo administrator password
- `MONGO_ADMIN_PASSWORD`
- `MONGO_DATA_DIR`
- `CRON_MINUTE`: Cron-specific minute
- `CRON_HOUR`: Cron-specific hour
- `CRON_DAY`: Cron-specific day
- `CRON_MONTH`: Cron-specific month
- `CRON_DAY_OF_WEEK`: Cron-specific day of week
- `BACKUP_DIR`
- `BACKUP_KEEP_COUNT`
- `BACKUP_RSYNC_SUBDIR`


## TODO section

- `REMOTE_BACKUP_HOST_SSH_CONNECTION_STRING`: use this string to set up the rsync ssh connection parameter (`-e` option). If not specified, rsync ssh remote connection not used and variable `$BACKUP_DIR` treated as local directory (must be passed as host directory volume to store backups on host machine). Some examples:

    - `/usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -l rsync_backup_user -i /root/.ssh/id_rsa`
    
        In this example, we explicitly set ssh binary (`/usr/bin/ssh`), and disable strict host key checking (`-o StrictHostKeyChecking=no`) to prevent interactive questions about remote server key. Also we disable host keys tracking with `-o UserKnownHostsFile=/dev/null` and login to remote server as rsync_backup_user (`-l rsync_backup_user`), using root private key (`-i /root/.ssh/id_rsa`). Note that private key of rsync_backup_user should be passed to container as hosted volume with `-v /your/private/key/location/id_rsa:/root/.ssh/id_rsa`.

    - `/usr/bin/ssh -o UserKnownHostsFile=/root/.ssh/known_hosts -l rsync_backup_user -i /root/.ssh/id_rsa`

        Same as above, but with enabled strict host key checking (by default) and using explicit file with known hosts (`-o UserKnownHostsFile=/root/.ssh/known_hosts`). It is assumed that this file already contains backup host key, so interactive question would not be asked. Note that both private key of rsync_backup_user and `known_hosts` file should be passed to container as hosted volume with `-v /your/private/key/location/id_rsa:/root/.ssh/id_rsa -v /your/known/hosts/location/known_hosts:/root/.ssh/known_hosts`.

    - `ssh -l rsync_backup_user`
    
        Same as above. By default ssh location is `/usr/bin/ssh`, strict host key checking is enabled. Do not forget `known_hosts` and `id_rsa` files: `-v /your/private/key/location/id_rsa:/root/.ssh/id_rsa -v /your/known/hosts/location/known_hosts:/root/.ssh/known_hosts`.


## Cron schedule

You can pass your cron schedule with `CRON_*` variables.
