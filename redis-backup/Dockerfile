FROM redis:alpine
LABEL maintainer="Andrey Andreev <andyceo@yandex.ru> (@andyceo)"
RUN apk update --no-cache && apk add rsync && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*
COPY ./redis-backup.sh /
RUN echo "37 * * * * /redis-backup.sh" | crontab -
CMD ["crond", "-f", "-L", "/dev/stdout"]
