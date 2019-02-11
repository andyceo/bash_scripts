FROM mongo:4.0
MAINTAINER Andrey Andreev <andyceo@yandex.ru> (@andyceo)
RUN apt-get update -qq && apt-get install -qqy --no-install-recommends cron rsync && \
    mkdir -p /backup/mongo/db && mkfifo --mode 0666 /var/log/mongo-backup.log && \
    apt-get clean && apt-get autoremove && rm -r /var/lib/apt/lists/* && rm -rf /tmp/* /var/tmp/*
COPY ./mongo-backup.sh /
COPY ./docker-entrypoint.sh /
CMD ["/docker-entrypoint.sh"]
