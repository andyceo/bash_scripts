FROM andyceo/pylibs
LABEL maintainer="Andrey Andreev <andyceo@yandex.ru> (@andyceo)"
COPY ["./requirements.txt", "./influxdb-schema.py", "./"]
RUN pip --no-cache-dir --disable-pip-version-check install -r requirements.txt && \
    rm -rf requirements.txt /tmp/* /var/tmp/*
ENTRYPOINT ["/app/influxdb-schema.py"]
CMD []
