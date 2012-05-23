#!/usr/bin/env bash

# Copy all MySQL databases (/var/lib/mysql) to tmpfs - file system
# in RAM.

# Author Name: Andrey Andreev aka andyceo
# Author Email: andyceo@yandex.ru
# Author Homepage: http://andyceo.ruware.com

# Source: http://tyomo4ka.blogspot.com/2011/10/mysql-5.html
# Other resources:
#  http://qa.drupal.org/performance-tuning-tips-for-D7
#  http://www.gnuman.ru/stuff/mysql_and_tmpfs/
#  http://mydebianblog.blogspot.com/2010/03/ramdisk-linux.html
#  http://citforum.ru/operating_systems/linux/robbins/fs03.shtml


echo -e "\e[1;35mWelcome to MySQL-to-memory script!\e[0m" 1>&2
echo

if [ "$UID" -ne "0" ]
then
  echo -e "\e[1;31mYou need to be root.\e[0m" 1>&2
  exit 1
fi

# define variables
folder=/var/lib/mysql
folder_tmp=/tmp/mysql2memory
root_uid=0
mysql_user=mysql
mysql_uid=`id -u $mysql_user`
mysql_gid=`id -g $mysql_user`
mysql_mode=0700
mounted=`mount | grep tmpfs | grep $folder`
# calculate mysql folder size and required memory amount
folder_size=`du -ksm $folder | awk '{ print $1 }'`
mount_size=`echo "$folder_size * 2" | bc`
# calculate free memory size and swap usage
free_memory_size=`free -m | awk '{print $4}' | sed -n '3p'`
swap_usage=`free -m | awk '{print $3}' | sed -n '4p'`


# Case for usual state: MySQL folder not mounted to memory
if [ -z "$mounted" ]
  then
    echo "Not mounted.

    MySQL status: `service mysql status`
    MySQL folder $folder not mounted to tmpfs.
    MySQL folder size: $folder_size M

    You need $mount_size M of memory to mount MySQL folder to tmpfs.
    Current system memory usage: $free_memory_size M free, swap usage: $swap_usage M"
    echo

    if [ "$mount_size" -lt "$free_memory_size" ]
      then
        echo "Do you want to mount MySQL folder to memory? (y/n, n is default)"
        read user_input
        if [ "$user_input" == "y" ]
          then
            service mysql stop
            set -e
            #create temporary tmpfs folder with mysql bases
            mkdir -p $folder_tmp
            chown $mysql_user: $folder_tmp
            chmod $mysql_mode $folder_tmp
            mount tmpfs $folder_tmp -t tmpfs -o size=`echo $mount_size`M,uid=$mysql_uid,gid=$mysql_gid,mode=$mysql_mode
            for i in $(ls $folder); do
              cp -apRL $folder/$i $folder_tmp/$i
            done
            # ... and mount this folder with copied db in memory instead MySQL datadir
            mount --move $folder_tmp $folder
            chown $mysql_user: $folder
            chmod $mysql_mode $folder
            #remove temporary data
            rm -r /tmp/mysql2memory
            service mysql start
        fi
      else
        echo "You have not enough free memory."
    fi
  else
    echo "Mounted.

    Unmount? (y/n, n is default)"
    read user_input
    if [ "$user_input" == "y" ]
      then
        service mysql stop
        umount $folder
        service mysql start
    fi
fi
