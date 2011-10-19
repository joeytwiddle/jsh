#!/bin/sh
optionalProcessName="$1"
# Don't lookup hostnames: -n
lsof -P -S 2 -V |
grep "^$optionalProcessName" |
grep ":" |
grep -v "\<REG\>" |
grep -v "Permission denied"
# highlight blue ".*Permission denied.*"
