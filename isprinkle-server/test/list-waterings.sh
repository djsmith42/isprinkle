#!/bin/bash

: ${host:=$host}

wget --quiet --output-document=- http://$host:8080/waterings
