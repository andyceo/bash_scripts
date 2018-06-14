FROM docker:stable
MAINTAINER Andrey Andreev <andyceo@yandex.ru> (@andyceo)
WORKDIR /app
COPY nc-exec.sh /app
EXPOSE 8130
ENTRYPOINT ["/bin/sh", "-c"]
CMD ["/app/nc-exec.sh"]
