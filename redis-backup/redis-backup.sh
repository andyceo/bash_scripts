#!/usr/bin/env sh

set -e

REDIS_HOST=${REDIS_HOST:-localhost}
REDIS_PORT=${REDIS_PORT:-6379}
REDIS_DIR=${REDIS_DIR:-/data}
BACKUP_DIR=${BACKUP_DIR:-/redisbackup}

echo
echo "Redis backups started at `date --utc -Iseconds`"
rsync -ahvz --stats --delete-after ${REDIS_DIR} ${BACKUP_DIR}
redis-cli -h ${REDIS_HOST} -p ${REDIS_PORT} --raw BGSAVE
# @TODO: change order of rsync and redis-cli, add reading of LASTSAVE status and wait for rsync backup
echo "Redis backups ended at `date --utc -Iseconds`"
echo
