FROM alpine
MAINTAINER Andrey Andreev <andyceo@yandex.ru> (@andyceo)
RUN apk update --no-cache && apk add rsync && mkfifo --mode 0666 /var/log/rsyncdir.log && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*
ENTRYPOINT ["/bin/sh", "-c", "/rsyncdir.sh"]
