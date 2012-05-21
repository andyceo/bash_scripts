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


echo "Welcome to MySQL-to-memory script!"
echo

echo -e "\e[1;31mroot permissions will be asked.\e[0m" 1>&2
sudo echo -e "\e[1;32mroot permission granted.\e[0m"
echo


# define variables
mounted=`mount | grep tmpfs | grep mysql`
folder=/var/lib/mysql
# calculate mysql folder size and required memory amount
folder_size=`sudo du -ksm $folder | awk '{ print $1 }'`
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
            sudo service mysql stop
            set -e

            #create temporary tmpfs folder with mysql bases
            sudo mkdir -p /tmp/mysql2memory
            sudo mount tmpfs /tmp/mysql2memory -t tmpfs -o size=`echo $folder_size`M
            sudo cp -apRL $folder /tmp/mysql2memory # "cp /from/* /to" not working on tmpfs

            # main work is here
            sudo mount tmpfs $folder -t tmpfs -o size=`echo $mount_size`M
            for i in $(sudo ls /tmp/mysql2memory/mysql); do
              sudo cp -apRL /tmp/mysql2memory/mysql/$i $folder/$i
            done
            #sudo chown mysql:mysql -R $folder

            #remove temporary data
            sudo umount /tmp/mysql2memory
            sudo rm -r /tmp/mysql2memory

            sudo service mysql start
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
        sudo service mysql stop
        sudo umount $folder
        sudo service mysql start
    fi
fi
