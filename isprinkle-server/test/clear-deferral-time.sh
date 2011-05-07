#!/bin/bash

: ${host:=$host}

tmpfile=/tmp/isprinkle-temp-file

echo "" > "$tmpfile"
wget http://$host:8080/clear-deferral-time --quiet -O - "--post-file=$tmpfile"
