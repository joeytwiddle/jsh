#!/bin/sh
# See also: monitorfolder (efficient, uses inotifywait)
# See also: watchforfileaccess

#jwatch listopenfiles -mergethreads . 2>/dev/null | grep -v "\<listopenfiles\>"

jwatch lsof -n -S 2 -V "$@" 2>/dev/null | grep -v "lsof\>"

# Bad: shows various lines from the jwatch process.
#jwatch eval "lsof -n -S 2 -V | grep -v '\<lsof\>'" 2>/dev/null
