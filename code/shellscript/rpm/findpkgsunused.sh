#!/bin/sh
'ls' -aultr /usr/bin | takecols 9 | head -n 100 | while read X; do  dlocate -S /usr/bin/$X | grep "/usr/bin/$X$";  done
