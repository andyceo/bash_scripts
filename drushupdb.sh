#!/usr/bin/env bash

# Update database for all Drupal multisiting installs

# Author Name: Andrey Andreev aka andyceo
# Author Email: andyceo@yandex.ru
# Author Homepage: http://andyceo.ruware.com

# ENGLISH NOTE: under development. Note that comments in this file
# and output messages in russian language generally.

# RUSSIAN NOTE:
#   Скрипт надо запускать из-под рута, для того, чтобы у него было достаточно прав
# изменить пользователя, под которым будет запущен drush.
# Если модули друпала что-то пишут в директории файлов при обновлении, то эти
# файлы будут сохранены с правами пользователя, из-под которых запущен drush.
# Переключиться на www-data можно командой "sudo su www-data".
# А для этого, понятно, нужно запустить срипт из-под root или использовать sudo.
#   Можно проставить у скрипта setuid равный www-data. делается это командами:
# cd <папка, где лежит этот скрипт>
# sudo chown www-data:www-data drushupdb.sh
# sudo chmod 4755 drushupdb.sh
# НО git не сохраняет пользователя. только права. так что на других компах все
# равно придется пользователя менять вручную.


ROOT_UID=0          # Только пользователь с $UID 0 имеет привилегии root.
WWW_USER=www-data   # Пользователь веб-сервера
WWW_GROUP=www-data  # Группа веб-сервера
EXIT=0              # если флаг не равен 0, то надо выйти
DRUPAL_DIRS="/var/www/drupal6 /var/www/drupal7"  # папки с друпалами
# @todo: добавить сайты и папки из настроек drush aliases.


if [ "$UID" -ne "$ROOT_UID" ]
then
  echo -e "\e[1;31mДля работы сценария требуются права root.\e[0m" 1>&2
  EXIT=1
fi


if which drush > /dev/null; then
  :
else
  echo -e "\e[1;31mНет команды drush.\e[0m" 1>&2
  EXIT=1
fi


if [ "$EXIT" != "0" ]; then
  echo -e "\e[1;31mАварийное завершение работы.\e[0m" 1>&2
  exit 1
fi



for dd in $DRUPAL_DIRS; do
  echo
  echo -e "  \e[45m Выполняем обновление баз данных всех сайтов Drupal, расположенных в папке $dd\e[0m"
  find $dd/sites -maxdepth 2 -mindepth 1 -name 'settings.php' -type f -not -path '*/all' -not -path '*/CVS' | sed -r 's/\/[^\/]+$//' | sort | uniq | while read x; do
    echo
    echo $x
    cd $x
    sudo -u $WWW_USER drush -r $dd --yes updb
  done
done
