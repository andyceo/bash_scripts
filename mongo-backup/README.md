# Mongo Backup Service

This is a docker service to backup data Mongo directory to specific remote host directory, or mounted local directory, by cron.

NOTE: for legacy reasons and compatibility with old version of this tool, use version `0.1.0` for backups! In `latest` and `0.2.0` versions environment variables changed their value! And can change them again in future.


## Quick start

By default, in case of your mongo is running in docker container, just provide host directories with Mongo data directory and backups:

    sudo docker run -d --net=mongo_default -e MONGO_HOST=mongo \
        -v /mongo/data/db/directory/on/host/system:/data/db:ro \
        -v /mongo/data/configdb/directory/on/host/system:/data/configdb:ro \
        -v /mongo/backup/directory/on/host/system:/mongobackup:rw \
        andyceo/mongo-backup

This will start container that will backup your mongo every day at 2:45 AM (UTC time). To just execute backup once, and provide Mongo admin user and authentication database, run:

    sudo docker run --rm --net=mongo_default -e MONGO_HOST=mongo \
        -e MONGO_AUTHENTICATION_DATABASE=admin \
        -e MONGO_ADMIN_PASSWORD="123qwe" \
        -v /mongo/data/db/directory/on/host/system:/data/db:ro \
        -v /mongo/data/configdb/directory/on/host/system:/data/configdb:ro \
        -v /mongo/backup/directory/on/host/system:/mongobackup:rw \
        andyceo/mongo-backup /mongo-backup.sh


## Configuration

Note that Mongo `db` and `configdb` directories from host system must always be mount to `/data/db` and `/data/configdb` directories inside mongo-backup container respectively. Also, backup directory on host system (ex. `/backups/mongo`) must always be mount to `/mongobackup` directory inside a container.

Mongo data directories `/data/db` and `/data/configdb` would be backed up with rsync to `/mongobackup` directory, so the result would be: `/mongobackup/db` and `/mongobackup/configdb`. After that, if `BACKUP_ARCHIVE_DIR` variable is provided, whole `/mongobackup` directory would be archived to `BACKUP_ARCHIVE_DIR` 

To configure this script (or service), use environment variables:

- `MONGO_HOST` (default is `localhost`): Mongo server domain or IP
- `MONGO_PORT` (default is `27017`): Mongo server listening port
- `MONGO_AUTHENTICATION_DATABASE`: Database to read user credentials from
- `MONGO_ADMIN_USERNAME` (default is `root`): Mongo server administrator user name
- `MONGO_ADMIN_PASSWORD_FILE` (default is `/run/secrets/root-at-mongo`): File that stores Mongo administrator password. Content of this file will be provided to `MONGO_ADMIN_PASSWORD` variable as-is, if `MONGO_ADMIN_PASSWORD` is not provided,
- `MONGO_ADMIN_PASSWORD` (default is `MONGO_ADMIN_PASSWORD_FILE` content): Mongo server administrator user password
- `CRON_MINUTE` (default is `45`): cron-specific minute
- `CRON_HOUR` (default is `2`): cron-specific hour
- `CRON_DAY` (default is `*`): cron-specific day
- `CRON_MONTH` (default is `*`): cron-specific month
- `CRON_DAY_OF_WEEK` (default is `*`): cron-specific day of week 
- `BACKUP_DIR` (default is `/mongobackup`): directory where to rsync Mongo databases (`db` and `configdb`). This variable value is used "as-is" in `rsync` as destination directory.
- `BACKUP_ARCHIVE_DIR` (no default value, not required): This directory will store `BACKUP_KEEP_COUNT` archived copies of `/mongobackup`. If no value provided, no archiving would be done.
- `BACKUP_KEEP_COUNT` (default is `3`): how many archived `mongo-TIMESTAMP.tgz` copies of data directory to store


## Volumes

This script (or docker container or docker swarm service) should be run on the same host with Mongo server itself. So for backup working correctly, you must provide three volumes, two with real MongoDB database directories and another is for backups itself.

Provide: 

- `-v /mongo/data/db:/data/db:ro` for host directory `/mongo/data/db` with Mongo data be passed to container at `/data/db` directory
- `-v /mongo/data/configdb:/data/configdb:ro` for host directory `/mongo/data/configdb` with Mongo data be passed to container at `/data/configdb` directory
- `-v /backup/mongo:/mongobackup:rw` for host directory `/backup/mongo` with Mongo backups be passed to container at `/mongobackup` directory


## Cron schedule

You can pass your cron schedule with `CRON_*` variables.


## TODO section

- `REMOTE_BACKUP_HOST_SSH_CONNECTION_STRING`: use this string to set up the rsync ssh connection parameter (`-e` option). If not specified, rsync ssh remote connection not used and variable `$BACKUP_DIR` treated as local directory (must be passed as host directory volume to store backups on host machine). Some examples:

    - `/usr/bin/ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -l rsync_backup_user -i /root/.ssh/id_rsa`
    
        In this example, we explicitly set ssh binary (`/usr/bin/ssh`), and disable strict host key checking (`-o StrictHostKeyChecking=no`) to prevent interactive questions about remote server key. Also we disable host keys tracking with `-o UserKnownHostsFile=/dev/null` and login to remote server as rsync_backup_user (`-l rsync_backup_user`), using root private key (`-i /root/.ssh/id_rsa`). Note that private key of rsync_backup_user should be passed to container as hosted volume with `-v /your/private/key/location/id_rsa:/root/.ssh/id_rsa`.

    - `/usr/bin/ssh -o UserKnownHostsFile=/root/.ssh/known_hosts -l rsync_backup_user -i /root/.ssh/id_rsa`

        Same as above, but with enabled strict host key checking (by default) and using explicit file with known hosts (`-o UserKnownHostsFile=/root/.ssh/known_hosts`). It is assumed that this file already contains backup host key, so interactive question would not be asked. Note that both private key of rsync_backup_user and `known_hosts` file should be passed to container as hosted volume with `-v /your/private/key/location/id_rsa:/root/.ssh/id_rsa -v /your/known/hosts/location/known_hosts:/root/.ssh/known_hosts`.

    - `ssh -l rsync_backup_user`
    
        Same as above. By default ssh location is `/usr/bin/ssh`, strict host key checking is enabled. Do not forget `known_hosts` and `id_rsa` files: `-v /your/private/key/location/id_rsa:/root/.ssh/id_rsa -v /your/known/hosts/location/known_hosts:/root/.ssh/known_hosts`.
