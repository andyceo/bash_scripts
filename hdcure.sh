#!/usr/bin/env bash

typeset -i i SECTOR MIN MAX rc

SECTOR=$1
DEVICE=/dev/sda

# Find MIN
let rc=1 i=SECTOR
while ((rc != 0)); do
    sudo hdparm --read-sector $i $DEVICE > /dev/null 2>&1
    rc=$?
    if [[ $rc != 0 ]]
    then
        echo "$i: bad"
        MIN=$i
        let i--
    else
        break;
    fi
done
echo "Found MIN: $MIN"

# Find MAX
let rc=1 i=SECTOR
while ((rc != 0)); do
    sudo hdparm --read-sector $i $DEVICE > /dev/null 2>&1
    rc=$?
    if [[ $rc != 0 ]]
    then
        echo "$i: bad"
        MAX=$i
        let i++
    else
        break;
    fi
done
echo "Found MAX: $MAX"

echo "Write zeros to [$MIN..$MAX?] (y/n)"

read ui

if [[ $ui == 'y' ]]
then
    for ((i=MIN;i<=MAX;i++)); do
        sudo hdparm --write-sector $i --yes-i-know-what-i-am-doing $DEVICE
    done
fi
