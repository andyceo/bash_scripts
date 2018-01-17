# Redis Backup Service

This is a docker service to backup Redis data directory to specific remote host directory, or mounted local directory.


## Quick start

By default, in case of your redis is running in docker container, just provide host directories with Redis data directory and backups:

    sudo docker run --rm --net=redis_default -e MONGO_HOST=redis \
        -v /redis/data/directory/on/host/system:/data:ro \
        -v /redis/backup/directory/on/host/system:/redisbackup:rw \
        andyceo/redis-backup
        
This will start container that will backup your redis and delete itself after.

Also take a look at provided `docker-compose.yml` for reference.


## Configuration

Note that Redis `data` directory from host system must always be mount to `/data` directory inside redis-backup container. Also, backup directory on host system (ex. `/backups/redis`) must always be mount to `/redisbackup` directory inside a container.

Redis data directory `/data` would be backed up with rsync to `/redisbackup` directory, so the result would be: `/redisbackup/data`.

To configure this script (or Docker service), use environment variables:

- `REDIS_HOST` (default is `localhost`): Redis server domain or IP
- `REDIS_PORT` (default is `6379`): Redis server listening port
- `REDIS_DIR` (default is `/data`): directory that store Redis databases. Note that this variable value would be used by rsync directly as source path, so be careful with trailing slashes. Typically you should not use this variable and mount directories from host system to default container directories with `docker -v` option instead of using this variable.
- `BACKUP_DIR` (default is `/redisbackup`): directory where to rsync Redis databases. This variable value is used "as-is" in `rsync` as destination directory. Typically you should not use this variable and mount directory from host system to default container directory with `docker -v` option instead of using this variable.
- `REDIS_BGSAVE_WAIT` (default is `30`): How many seconds (maximum) wait LASTSAVE change from sending BGSAVE moment.

Note that you typically should not use variables `REDIS_DIR`, `BACKUP_DIR` but mount host directories to default container directories instead. This variables are designed to customize script behaviour in case it executed on host system directly, not in container environment.


## Volumes

This script (or docker container or docker swarm service) should be run on the same host with Redis server itself. So for backup working correctly, you must provide two volumes, one with real Redis database directory and another is for backups itself.

Provide:

- `-v /redis/data:/data:ro` for host directory `/redis/data` with Redis data be passed to container at `/data` directory
- `-v /backup/redis:/redisbackup:rw` for host directory `/backup/redis` with Redis backups be passed to container at `/redisbackup` directory
