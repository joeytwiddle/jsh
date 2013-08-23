#!/bin/sh
optionalProcessName="$1"
# Don't lookup hostnames: -n
lsof -P -S 2 -V |
grep --line-buffered "^$optionalProcessName" |
grep --line-buffered ":" |
grep --line-buffered -v "\<REG\>" |
grep --line-buffered -v "Permission denied"
# highlight blue ".*Permission denied.*"
