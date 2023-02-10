#!/usr/bin/env bash

curl --insecure --head --header 'Accept-Encoding: gzip,deflate' "$1" | grep "Content-Encoding"
