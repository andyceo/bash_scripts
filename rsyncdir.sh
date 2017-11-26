#!/usr/bin/env bash

set -e

SOURCE=${SOURCE:-}
DESTINATION=${DESTINATION:-}

echo
echo "Directory backup (from $SOURCE to $DESTINATION) started at `date --utc --iso-8601=seconds`"

if [[ -z "${SOURCE}" ]]; then
    echo "Source directory not set! Exiting..."
    exit 1
fi

if [[ -z "${DESTINATION}" ]]; then
    echo "Destination directory not set! Exiting..."
    exit 2
fi

rsync -ahvz --stats --delete-after ${SOURCE} ${DESTINATION}

echo "Directory backups (from $SOURCE to $DESTINATION) ended at `date --utc --iso-8601=seconds`"
echo

# @todo: logic for trying rsync until no files are changed during rsync
