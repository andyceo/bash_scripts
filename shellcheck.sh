#!/usr/bin/env bash

apt install shellcheck

find . -type f -name "*.sh" -exec bash -n {} \;
find . -type f -name "*.sh" -exec shellcheck {} \;
