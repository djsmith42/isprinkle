#!/bin/bash

: ${host:=$host}

uuid="$1"
tmpfile=/tmp/isprinkle-temp-file

if [ -z "$uuid" ]; then
    echo "Usage: $0 <uuid of watering to disable>"
    exit 1
fi

echo "$uuid" > "$tmpfile"
wget http://$host:8080/disable-watering --quiet -O - "--post-file=$tmpfile"
echo
