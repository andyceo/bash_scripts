#!/usr/bin/env bash

# Sync the site's local development copy with production one

# Author Name: Andrey Andreev aka andyceo
# Author Email: andyceo@yandex.ru
# Author Homepage: http://andyceo.ruware.com

# ENGLISH NOTE: under development. Note that comments in this file
# and output messages in russian language generally.

# RUSSIAN NOTE:
# ВАЖНО! Перед использованием скрипта, настройте корректно drush aliases.
# Скрипт помогает развернуть копию удаленного сайта на локальный компьютер для разработки.
# @arguments:
#   $1 - from - сайт-источник данных. drush site alias.
#   $2 - to - сайт-приемник данных. drush site alias.
# Example: ./drushsync.sh @example.com @example.local


WWW_USER=www-data

from=$1
to=$2

# узнаем путь до файлов на разработческой площадке
files=`drush $to dd %files`

# @todo: проверка значений, фильтрация

# сначала синхронизируем файлы, предварительно вернув нужные права
sudo chown -R $USER $files
drush rsync $from:%files $to:%files --yes

# потом базку
drush $to sql-drop --yes
drush sql-sync --no-cache $from $to --yes

# @todo заменить в БД вхождения $from на $to

# sanitize 1-го пользователя, вручную, sanitize от drush почему-то не срабатывает
drush $to sql-query "UPDATE {users} SET name='admin', pass='`echo -n '123' | md5sum`' WHERE uid=1"

# установим корректный путь до директории files
drush $to vset --yes file_directory_path $files

# проставим корректного владельца у %files, после rsync он будет $USER
sudo chown -R $WWW_USER: $files
