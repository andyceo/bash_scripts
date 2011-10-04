#!/usr/bin/env bash

# Installing VM using VirtualBox virtual machine

# Author Name: Andrey Andreev aka andyceo
# Author Email: andyceo@yandex.ru
# Author Homepage: http://andyceo.ruware.com

# ENGLISH NOTE: under development. Note that comments in this file
# and output messages in russian language generally.

# RUSSIAN NOTE:
# Полезные ссылки:
#   http://habrahabr.ru/blogs/personal/60325/
#   http://www.virtualbox.org/manual/ch08.html
#   http://www.opennet.ru/docs/RUS/bash_scripting_guide/
# Полезные команды:
#   VBoxManage list vms - список всех виртуальных машин
#   VBoxManage unregistervm "<uuid>|<name>" --delete - дерегистрирует и удаляет файл виртуальной машины
#   VBoxManage closemedium disk|dvd|floppy "<uuid>|<filename>" --delete - удаление disk|dvd|floppy


vmname=$1  # virtual machine name. first param of this script
hdname="/home/andyceo/.VirtualBox/HardDisks/$vmname.vdi"   # для сервера Ubuntu 10.04.3
#hdname="/home/andyceo/VirtualBox VMs/$vmname/$vmname.vdi"  # для настольной Ubuntu 11.04
hdsize=1536  # size in megabytes. = 1.5 Gb

echo "Creating Windows XP virtual machine " $vmname

if [ "$vmname" ]
then
  :
else
  echo -e "\e[1;31mИмя виртуальной машины не задано.\e[0m" 1>&2
  exit 1
fi

VBoxManage createvm --name $vmname --ostype WindowsXP --register
VBoxManage createhd --filename "$hdname" --size $hdsize --format VDI #--variant Fixed  # диск фиксированного размера создается долго

VBoxManage storagectl $vmname --name IDEController --add ide --controller PIIX4 --bootable on
VBoxManage storageattach $vmname --storagectl IDEController --port 0 --device 0 --type hdd --medium "$hdname"

VBoxManage modifyvm $vmname --memory 128 --vram 16 --acpi on --ioapic off --pae off
VBoxManage modifyvm $vmname --boot1 disk --boot2 dvd --boot3 floppy --boot4 none
VBoxManage modifyvm $vmname --nictype1 82540EM --nic1 nat
VBoxManage modifyvm $vmname --usb off --audio none
