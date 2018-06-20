FROM docker:stable
LABEL maintainer="Andrey Andreev <andyceo@yandex.ru> (@andyceo)"
RUN apk add --update --no-cache curl grep netcat-openbsd && rm -rf /var/cache/apk/* /tmp/* /var/tmp/*
WORKDIR /app
COPY nc-exec.sh /app
EXPOSE 8130
ENTRYPOINT ["/bin/sh", "-c"]
CMD ["/app/nc-exec.sh"]
