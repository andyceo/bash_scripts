#!/usr/bin/env bash

function config_file () {
  DEFAULT_CONFIG="#This is the default DAR configuration section.
create:
  # upon creation exclude the
  # following files from compression
  # archives
    -Z '*.mpg' -Z '*.gz' -Z '*.bz2' -Z '*.zip'
  # images
    -Z '*.jpg' -Z '*.jpeg' -Z '*.gif' -Z '*.png' -Z '*.ico'
  # audio
    -Z '*.mp3' -Z '*.ogg'
  # other media
    -Z '*.avi' -Z '*.mkv'

all:
  -m 256
  -y9
  -s 200M
  -D
  -q

default:
  # this will get read if not
  # command has been set yet
  -V
  # thus by default dar shows its version

all:
  #-v
  # for any command we also ask to be verbose
  # this is added to the previous all: condition
"
  CONFIG_FILE=$(tempfile)
  echo "$DEFAULT_CONFIG" > $CONFIG_FILE
  echo -ne "#This config taken from user config file $1\n" >> $CONFIG_FILE
  echo -n "`cat $1`" >> $CONFIG_FILE
  echo $CONFIG_FILE # return file name to caller
}

function extract_variable () {
  echo `cat $1 | grep $2 | head -n1 | sed "s/##$2=//"` #return variable value
}

function last_backup () {
  BACKUP_TYPE=$1
  LAST=`ls $DESTINATION_DIRECTORY/$TASK_NAME"_"*"_"$BACKUP_TYPE.*.dar 2>/dev/null | tail -1`
  TIMESTAMP="0"
  if [ -n "$LAST" ]
  then
    LAST=$(basename $LAST .1.dar 2>/dev/null)
    TIMESTAMP=$(echo $LAST | sed "s/$TASK_NAME"_"//" | sed "s/"_"$BACKUP_TYPE//")
    TIMESTAMP=`date --utc --date $TIMESTAMP +%s`
  fi
  case "$BACKUP_TYPE" in
    "full" )
      LAST_FULL=$LAST
      LAST_FULL_TIMESTAMP=$TIMESTAMP
    ;;
    "diff" )
      LAST_DIFF=$LAST
      if [ "$TIMESTAMP" == "0" ]; then TIMESTAMP=$LAST_FULL_TIMESTAMP; fi
      LAST_DIFF_TIMESTAMP=$TIMESTAMP
  esac
}

function dump_vars() {
  echo 'DUMPING GLOBAL SCRIPT VARIABLES...'
  echo "task name: $TASK_NAME"
  echo "last full backup: $LAST_FULL"
  echo "last full backup timestamp: $LAST_FULL_TIMESTAMP"
  echo "current timestamp: $CURRENT_TIMESTAMP"
  echo "last diff backup: $LAST_DIFF"
  echo "last diff backup timestamp: $LAST_DIFF_TIMESTAMP"
}

## MAIN FLUX
if [ ! -f "$1" ]
then
  echo -e "\e[1;31mConfig file not exists: $1\e[0m" 1>&2
  exit 1
fi
TASK_NAME=`basename $1 .dcf`
CONFIG_FILE=`config_file $1`
SOURCE_DIRECTORY=`cat $1 | grep "\-R " | head -n1 | sed "s/-R //"`
DESTINATION_DIRECTORY="`extract_variable $1 DESTINATION_DIRECTORY`/$TASK_NAME"
mkdir -p $DESTINATION_DIRECTORY
# @TODO: make sure that DESTINATION is not subdirectory of SOURCE
# @TODO: check following variables
BACKUP_FULL_PERIOD=`extract_variable $1 BACKUP_FULL_PERIOD`
BACKUP_DIFF_PERIOD=`extract_variable $1 BACKUP_DIFF_PERIOD`
CURRENT_UTC_DATE=`date -Isecond --utc | sed "s/+0000//"`
CURRENT_TIMESTAMP=`date --utc --date $CURRENT_UTC_DATE +%s`
LAST_FULL=""
LAST_FULL_TIMESTAMP="0"
LAST_DIFF=""
LAST_DIFF_TIMESTAMP="0"
# update global LAST_* variables in function last_backup():
last_backup full
last_backup diff

# check for full backup expiration
if [ `echo "($CURRENT_TIMESTAMP - $LAST_FULL_TIMESTAMP) > $BACKUP_FULL_PERIOD * 3600" | bc` == "1" ]
then
  echo 'Create new full backup, clean the old one'
  dar -c $DESTINATION_DIRECTORY/$TASK_NAME"_"$CURRENT_UTC_DATE"_full" -B $CONFIG_FILE
  # @TODO: clean old backups
else
  # check the latest diff, and create new diff backup if expired
  echo 'No need to create full backup'
  if [ `echo "($CURRENT_TIMESTAMP - $LAST_DIFF_TIMESTAMP) > $BACKUP_DIFF_PERIOD * 3600" | bc` == "1" ]
  then
    echo 'Create diff backup'
    # @TODO: Remove restriction of one slice (.1.dar)
    LAST=`ls $DESTINATION_DIRECTORY/$TASK_NAME"_"*.1.dar | tail -1 | sed "s/.1.dar//"`
    dar -c $DESTINATION_DIRECTORY/$TASK_NAME"_"$CURRENT_UTC_DATE"_diff" -B $CONFIG_FILE -A $LAST
  else
    echo 'No need to create diff backup'
  fi
fi
rm $CONFIG_FILE
exit 0

# @TODO: testing backup after creation

#for i in $TARGETS; do
  #filename=$(echo $i | sed 's/\//-/g'); #убираем / в имени файла
  #tar -czPf /var/archives/`echo $HOSTNAME`$filename-`date +%Y%m%d`.tar.gz $i; # e.g. gbox-etc-20100314.tar.gz
#done

#echo '----------'

#for i in `ls /var/archives/`; do
  #gpg -e --symmetric --cipher-algo AES --batch --passphrase «Your_Password» /var/archives/$i; # шифруем
  #mv /var/archives/$i.gpg /home/allein/Dropbox/archives/; # шифрованные файлы закидуем на Dropbox
  #rm -f /var/archives/$i; # остальное удаляем
#done
