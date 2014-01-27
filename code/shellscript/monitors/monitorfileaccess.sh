#!/bin/sh
# See also: watchforfileaccess
jwatch listopenfiles -mergethreads . 2>/dev/null | grep -v "\<listopenfiles\>"
