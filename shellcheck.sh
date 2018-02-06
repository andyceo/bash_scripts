#!/usr/bin/env sh

# This script use shellcheck to verify shell scripts. On Ubuntu, you can install it with:
#
#   apt install shellcheck
#
# Also, if you are sure that your script is bash script (not sh, zsh etc), you can use for syntax check:
#
#   find . -type f -name "*.sh" -print0 | xargs -n 1 -0 bash -n

find . -type f -name "*.sh" -print0 | xargs -n 1 -0 shellcheck
