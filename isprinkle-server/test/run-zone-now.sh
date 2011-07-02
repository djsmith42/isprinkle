#!/bin/bash

: ${host:=$host}

zone="$1"
minutes="$2"
tmpfile=/tmp/isprinkle-temp-file.$$.$USER

if [ -z "$zone" -o -z "$minutes" ]; then
    echo "Usage: $0 <zone number> <minutes>"
    exit 1
fi

echo "$zone $minutes" > "$tmpfile"
wget http://$host:8080/run-zone-now --quiet -O - "--post-file=$tmpfile"
rm -f "$tmpfile"

echo
