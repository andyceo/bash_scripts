#!/usr/bin/env sh

set -e

REDIS_HOST=${REDIS_HOST:-localhost}
REDIS_PORT=${REDIS_PORT:-6379}
REDIS_DIR=${REDIS_DIR:-/data}
REDIS_BGSAVE_WAIT=${REDIS_BGSAVE_WAIT:-30}
BACKUP_DIR=${BACKUP_DIR:-/redisbackup}

echo
echo "Redis backups started at `date --utc -Iseconds`"

TIMESTAMP_BEFORE_BGSAVE=`redis-cli -h ${REDIS_HOST} -p ${REDIS_PORT} --raw LASTSAVE`
DATETIME_BEFORE_BGSAVE=`date --utc -Iseconds --date=${TIMESTAMP_BEFORE_BGSAVE}`
echo "Last save was at ${TIMESTAMP_BEFORE_BGSAVE} (${DATETIME_BEFORE_BGSAVE}), sending BGSAVE..."
redis-cli -h ${REDIS_HOST} -p ${REDIS_PORT} --raw BGSAVE
echo "Waiting for ${REDIS_BGSAVE_WAIT} seconds..."

REDIS_BGSAVE_WAIT_PAST=0
while [ "${REDIS_BGSAVE_WAIT}" -gt "${REDIS_BGSAVE_WAIT_PAST}" ];
do
    TIMESTAMP_LASTSAVE=`redis-cli -h ${REDIS_HOST} -p ${REDIS_PORT} --raw LASTSAVE`
    if [ "${TIMESTAMP_LASTSAVE}" -eq "${TIMESTAMP_BEFORE_BGSAVE}" ]
    then
        echo "Wait for 1 second - ${REDIS_BGSAVE_WAIT_PAST}..."
        sleep 1
    else
        echo "LASTSAVE changed (now ${TIMESTAMP_LASTSAVE}, was ${TIMESTAMP_BEFORE_BGSAVE}), breaking wait loop..."
        break
    fi
    REDIS_BGSAVE_WAIT_PAST=$((REDIS_BGSAVE_WAIT_PAST + 1))
done

rsync -ahvz --stats --delete-after ${REDIS_DIR} ${BACKUP_DIR}

echo "Redis backups ended at `date --utc -Iseconds` "
echo
