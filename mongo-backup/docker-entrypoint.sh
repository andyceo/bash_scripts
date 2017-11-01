#!/usr/bin/env bash

set -e

CRON_MINUTE=${CRON_MINUTE:-"45"}
CRON_HOUR=${CRON_HOUR:-"2"}
CRON_DAY=${CRON_DAY:-"*"}
CRON_MONTH=${CRON_MONTH:-"*"}
CRON_DAY_OF_WEEK=${CRON_DAY_OF_WEEK:-"*"}

echo "${CRON_MINUTE} ${CRON_HOUR} ${CRON_DAY} ${CRON_MONTH} ${CRON_DAY_OF_WEEK} root /mongo-backup.sh >> /var/log/mongo-backup.log 2>&1" >> /etc/cron.d/mongo-backup

# Further logic are inspired by https://hub.docker.com/r/renskiy/cron/
# @see https://hub.docker.com/r/renskiy/cron/
# @see https://github.com/renskiy/cron-docker-image
# @see https://github.com/renskiy/cron-docker-image/blob/master/debian/start-cron
# @see https://habrahabr.ru/company/redmadrobot/blog/305364/ (russian)

# update default values of PAM environment variables (used by CRON scripts)
env | while read -r line; do  # read STDIN by line
    # split LINE by "="
    IFS="=" read var val <<< ${line}
    # remove existing definition of environment variable, ignoring exit code
    sed --in-place "/^${var}[[:blank:]=]/d" /etc/security/pam_env.conf || true
    # append new default value of environment variable
    echo "${var} DEFAULT=\"${val}\"" >> /etc/security/pam_env.conf
done

# start cron
service cron start

# trap SIGINT and SIGTERM signals and gracefully exit
trap "service cron stop; kill \$!; exit" SIGINT SIGTERM

# start "daemon"
while true
do
    # watch /var/log/mongo-backup.log restarting if necessary
    cat /var/log/mongo-backup.log & wait $!
done
