#!/usr/bin/env bash

apt install shellcheck

find . -type f -name "*.sh" -print0 | xargs -n 1 -0 bash -n
find . -type f -name "*.sh" -print0 | xargs -n 1 -0 shellcheck
