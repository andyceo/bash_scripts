#!/usr/bin/env bash

if [ $# -eq 0 ]; then
    echo "No arguments supplied. Usage: $0 <DIRECTORY> You should pass exactly one argument - the directory which contains root directories hierarchy as following: /directory/etc-nginx, /directory/etc/apache, etc. Only second-level root directories simlinks are supported by now. Example: $0 /directory"
    exit 1
fi

if [ -d "${1}" ]; then
    for D in "${1%/}"/*; do
        if [ -d "${D}" ]; then
            DO="${D}"
            D=/`basename "${D}" | sed 's/-/\//g'`
            echo "${DO} detected and treated as ${D}"

            if [ -L "${D}" ]; then
                echo "${D} is already simlinked to `readlink ${D}`, skipping..."
            else
                DN="`dirname "${D}"`/`basename "${D}"`_old"
                mv "${D}" "${DN}"
                echo "${D} moved from ${D} to ${DN}"

                ln -s "${DO}" "${D}"
                echo "${D} symlinked to ${DN}"
            fi
            echo
        fi
    done
else
    echo "Passed directory does not exists"
    exit 2
fi
