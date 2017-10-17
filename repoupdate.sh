#!/usr/bin/env bash

# Original file was modified 2013-09-23 15:03:23.000000000 +0400
# and last edited 2014-12-15 11:29:47.414363278 +0300

dir=`pwd`
find * -maxdepth 0 -type d | while read j; do
  cd $j
  if [ -d ".git" ]; then
    if [ -d ".git/svn" ]; then
      echo "----------- $j - This is GIT SVN -----------"
      git svn rebase
    else
      echo "----------- $j - This is GIT -----------"
      git pull
    fi
  elif [ -d "svn" ]; then
    echo "----------- $j - This is SVN -----------"
    svn up
  else
    echo "----------- $j - UNKNOWN -----------"
  fi;
  cd $dir
  echo "--------------"
  echo
done
