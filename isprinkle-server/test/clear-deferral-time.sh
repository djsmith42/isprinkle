#!/bin/bash

tmpfile=/tmp/isprinkle-temp-file

echo "" > "$tmpfile"
wget http://localhost:8080/clear-deferral-time --quiet -O - "--post-file=$tmpfile"
