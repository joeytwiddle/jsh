#!/bin/sh

# -l = show only listening ports; if you want to see outgoing connections, you might not want this
# -p = show PID and program name
# -n = do not resolve hostnames (which would be slow)
netstat -pn | grep -e "$1"
exit

# Old way; much slower (but shows lots of detail; more than we need!)
optionalProcessName="$1"
# Don't lookup hostnames: -n
lsof -P -S 2 -V |
grep --line-buffered "^$optionalProcessName" |
grep --line-buffered ":" |
grep --line-buffered -v "\<REG\>" |
grep --line-buffered -v "Permission denied"
# highlight blue ".*Permission denied.*"
