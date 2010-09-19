#!/bin/bash

datetime="$1"
tmpfile=/tmp/isprinkle-temp-file

if [ -z "$datetime" ]; then
    echo "Usage: $0 <yyyy-mm-dd hh:mm:ss>"
    exit 1
fi

echo "$datetime" > "$tmpfile"
wget http://localhost:8080/set-deferral-time --quiet -O - "--post-file=$tmpfile"
