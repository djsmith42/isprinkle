#!/bin/bash

: ${host:=$host}

wget --quiet -O - http://$host:8080/status
