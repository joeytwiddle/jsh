#!/bin/sh
jzcat /var/log/dpkg.log* | grep "^[^ ]* *[^ ]* *\<\(install\|remove\|purge\|upgrade\)\>" | sort -k 1,2
