#!/bin/bash

: ${host:=$host}

wget http://$host:8080/delete-all-single-shot-waterings --quiet -O - "--post-file=/dev/null"
echo
