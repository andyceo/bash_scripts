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
#     $ echo run v2.14.0-RC1 | nc -q 0 10.1.20.115 54321
#
##################################################################################################################

while true ; do

  input=$(nc -l -q 0 -p 54321)

  echo "Received: $input"

  command=${input%% *}
  tag=${input##* }

  if [ "$command" = "run" ] && [ -n "$tag" ]
  then

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

  else

    echo "Unknown command: $command, or tag: $tag"

  fi

done
