#!/usr/bin/env bash

# SCRIPT NOT READY AND NOT TESTED! JUST DRAFT!

set -e

SOURCE=${SOURCE:-}
DESTINATION=${DESTINATION:-}
NAME=${NAME:-}

echo
echo "Directory archiving (from $SOURCE to $DESTINATION) started at `date --utc --iso-8601=seconds`"

if [[ -n "${ARCHIVE_DIRECTORY}" && -n "${NAME}" ]]; then
    echo "Archiving synced directory... (`date --utc --iso-8601=seconds`)"
    TIMESTAMP=$(date --utc --iso-8601=seconds)
    tar czf "${ARCHIVE_DIRECTORY}/${NAME}[${TIMESTAMP}].tgz" "${DESTINATION}"
    echo "Archiving done (`date --utc --iso-8601=seconds`)"
fi

echo "Directory backups (from $SOURCE to $DESTINATION) ended at `date --utc --iso-8601=seconds`"
echo

# @todo logic for deleting source directory
