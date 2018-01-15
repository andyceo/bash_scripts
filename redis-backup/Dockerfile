FROM redis:4-alpine
MAINTAINER Andrey Andreev <andyceo@yandex.ru> (@andyceo)
RUN apk update --no-cache && apk add rsync && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*
COPY ./redis-backup.sh /
CMD ["/redis-backup.sh"]
