#!/bin/sh
# See also: monitorfolder (efficient, uses inotifywait)
# See also: watchforfileaccess
jwatch listopenfiles -mergethreads . 2>/dev/null | grep -v "\<listopenfiles\>"
