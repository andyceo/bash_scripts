#!/usr/bin/env bash

set -e

RSYNCDIR_SOURCE=${1:-${RSYNCDIR_SOURCE:-}}
RSYNCDIR_DESTINATION=${2:-${RSYNCDIR_DESTINATION:-}}

echo
echo "Directory backup (from $RSYNCDIR_SOURCE to $RSYNCDIR_DESTINATION) started at `date --utc --iso-8601=seconds`"
rsync -ahvz --stats --delete-after ${RSYNCDIR_SOURCE} ${RSYNCDIR_DESTINATION}
# @todo: add optional logic for trying rsync until no files are changed during rsync
echo "Directory backups (from $RSYNCDIR_SOURCE to $RSYNCDIR_DESTINATION) ended at `date --utc --iso-8601=seconds`"
echo
