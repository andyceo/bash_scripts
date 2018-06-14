#!/bin/sh

##################################################################################################################
#
# The main usecase of this script is run new version of your dockerized application on one server, from another.
#
# Run this on server on which you want to execute this! This script must be run with root priveleges. See:
#
#     $ sudo su
#     $ nohup ./nc-exec.sh 0<&- &> /var/log/nc-exec.log &
#
# Run this to watch logs:
#
#     $ sudo tail -f -n 100 /var/log/nc-exec.log
#
# Run this on server from which execute this:
#
#     $ echo run v2.14.0-RC1 | nc -q 0 10.1.20.115 8180
#
##################################################################################################################

PORT=8180
SOCKET_PATH=/var/run/docker.sock
STEP=1

echo "Script started!"
while true ; do

  echo "Step ${STEP}: listening..."

  input=$(nc -l -q 0 -p ${PORT})

  command=$(echo ${input} | cut -d' ' -f1)
  arg1=$(echo ${input} | cut -d' ' -f2)
  arg2=$(echo ${input} | cut -d' ' -f3)
  arg3=$(echo ${input} | cut -d' ' -f4)

  echo
  echo "Received: ${input}, parsed as:"
  echo "Command: ${command}"
  echo "  ARG_1: ${arg1}"
  echo "  ARG_2: ${arg2}"
  echo "  ARG_3: ${arg3}"

  echo

  case "${command}" in
    "run")
      tag="${arg1}"

      echo "Re-run containers version $tag :"

      CONTAINERS="test1.example.com test2.example.com"
      for name in $CONTAINERS
      do
        if docker top $name &>/dev/null
        then
          docker rm -f $name
        fi
      done

      PORT_PREFIX=2001 && docker run -d -p `echo $PORT_PREFIX+80|bc`:80 --name test1.example.com -h test1.example.com --restart always --link redis-master --link redis-slave --link memcached -e APP_ENV=dev -e APP_HOST=test1.example.com build.example.com:5000/example.com/app:$tag

      PORT_PREFIX=2002 && docker run -d -p `echo $PORT_PREFIX+80|bc`:80 --name test2.example.com -h test2.example.com --restart always --link redis-master --link redis-slave --link memcached -e APP_ENV=stage -e APP_HOST=test2.example.com build.example.com:5000/example.com/app:$tag

      docker images --format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}" | grep "example.com/app" | grep -v $tag | cut -d" " -f1 | xargs docker rmi

      ;;

    "service-update")
      service="${arg1}"
      image="${arg2}"
      if [ -z "${service}" ] || [ -z "${image}" ]; then
        echo "Wrong service-update command arguments! Service and image both must be set."
      else
        version=$(curl -s --unix-socket ${SOCKET_PATH} "http:/services/${service}" | grep -oP 'Version.*?Index.*?\d.*?},' | grep -oP '\d+')
        curl --unix-socket ${SOCKET_PATH} -v -H 'Content-Type: application/json' -d ' { "name": "'"${service}"'", "TaskTemplate":{ "ContainerSpec": { "Image": "'"${image}"'", "Runtime": "container" } } }' "http:/services/${service}/update?version=${version}"
      fi
      ;;
    *)
      echo "Unknown command: ${command}, or tag: ${tag}, nothing to do"
      ;;
  esac

  STEP=$(expr ${STEP} + 1)

done
