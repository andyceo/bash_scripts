#!/usr/bin/env bash

set -e

MONGO_HOST=${MONGO_HOST:-localhost}
MONGO_PORT=${MONGO_PORT:-27017}
MONGO_AUTHENTICATION_DATABASE=${MONGO_AUTHENTICATION_DATABASE:-}
MONGO_ADMIN_USERNAME=${MONGO_ADMIN_USERNAME:-root}
MONGO_ADMIN_PASSWORD_FILE=${MONGO_ADMIN_PASSWORD_FILE:-/run/secrets/root-at-mongo}
MONGO_ADMIN_PASSWORD=${MONGO_ADMIN_PASSWORD:-${MONGO_AUTHENTICATION_DATABASE:+`cat ${MONGO_ADMIN_PASSWORD_FILE}`}}
BACKUP_ARCHIVE_DIR=${BACKUP_ARCHIVE_DIR:-}
BACKUP_KEEP_COUNT=${BACKUP_KEEP_COUNT:-3}

function mongo_eval {
    if [[ -z "${MONGO_AUTHENTICATION_DATABASE}" ]]; then
        mongo ${MONGO_HOST}:${MONGO_PORT} --quiet --eval "printjson($1)"
    else
        mongo ${MONGO_HOST}:${MONGO_PORT} -u ${MONGO_ADMIN_USERNAME} -p ${MONGO_ADMIN_PASSWORD} \
            --authenticationDatabase ${MONGO_AUTHENTICATION_DATABASE} --quiet --eval "printjson($1)"
    fi
}

echo
echo "MongoDB backups started at `date --utc --iso-8601=seconds`"
mongo_eval "db.fsyncLock()"
set +e
rsync -ahvz --stats --delete-after /data/db /mongobackup
rsync -ahvz --stats --delete-after /data/configdb /mongobackup
mongo_eval "db.fsyncUnlock()"
set -e

if [[ -n "${BACKUP_ARCHIVE_DIR}" ]]; then
    TIMESTAMP=$(date --utc --iso-8601=seconds)
    tar czf ${BACKUP_ARCHIVE_DIR}/mongobackup[${TIMESTAMP}].tgz /mongobackup
    find ${BACKUP_ARCHIVE_DIR} -maxdepth 1 -type f -name "mongobackup*.tgz" | sort -rn | awk " NR > $BACKUP_KEEP_COUNT" | while read f; do echo "Removing $f..."; rm ${f}; done
fi

echo "MongoDB backups ended at `date --utc --iso-8601=seconds`"
echo
