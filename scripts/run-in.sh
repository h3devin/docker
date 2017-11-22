#!/bin/bash

if (( $# < 2 )); then
    echo "usage: run-in.sh /path/from/var/www <command>"
    exit 1
fi

cd "/var/www/$1"
"${@:2:$#}"