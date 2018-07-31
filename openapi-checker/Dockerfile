FROM python:3-alpine
LABEL maintainer="Andrey Andreev <andyceo@yandex.ru> (@andyceo)"
WORKDIR /app
COPY ["./requirements.txt", "./openapi-checker.py", "./"]
RUN apk add --update --no-cache ca-certificates && \
    pip --no-cache-dir --disable-pip-version-check install -r requirements.txt && \
    rm -rf requirements.txt /tmp/* /var/tmp/*
ENTRYPOINT ["/app/openapi-checker.py"]
CMD []
