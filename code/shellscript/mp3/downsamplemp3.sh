#!/bin/sh
## Defaults 48khz out
mpg123 -w - "$1" |
## Defaults 48khz in
## But only MPEG layer 2
toolame -b 128 /dev/stdin "LOWER_$1"
