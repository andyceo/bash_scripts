#!/usr/bin/env bash

# SCRIPT NOT READY AND NOT TESTED! JUST DRAFT!

# @see https://docs.influxdata.com/influxdb/v1.4/administration/backup_and_restore
# @see https://docs.influxdata.com/influxdb/v1.3/tools/shell/

INFLUXD_EXECUTABLE=influxd
INFLUXDB_DOCKER_SERVICE_NAME=influxdb



# Вариант 2 скрипта бэкапа

# Найти контейнер сервиса с influxdb
for f in $(sudo docker service ps -q databases_influxdb); do sudo docker inspect --format '{{.NodeID}} {{.Status.ContainerStatus.ContainerID}}' $f; done
# взять первый, к нему будем делать docker exec

# Получить список всех БД

# Сделать бекап всех метаданных
# S1: influxd backup /path/to/metadata

# В цикле по БД сделать бекап каждой БД
# S1: influxd backup -database mydatabase /path/to/backup

# Опционально: сделать rsync основной папки influxdb



# Вариант 1 скрипта бэкапа

# пересоздать сервис InfluxDB, замонтировав туда папку с бекапами

# найдем контейнер сервиса
IDBCID=$(docker inspect --format '{{.Status.ContainerStatus.ContainerID}}' \
    $(docker service ps -q ${INFLUXDB_DOCKER_SERVICE_NAME} --filter "desired-state=running"))

# получим список баз данных (нужны admin credentials. а то ругается)

docker container exec $IDBCID influx -execute 'SHOW DATABASES'

# выполним бекап хранилища мета-информации (metastore)

docker container exec $IDBCID influxd backup /backup

# выполним бекап каждой базы данных

# почистим устаревшие бекапы
