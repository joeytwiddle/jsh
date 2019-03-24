#!/bin/sh
# This will slow your system down, but it may be useful when testing performance.  (If you don't want a second run to benefit from caching made by the first run.)
# Probably requires root privileges!

sync; echo 3 > /proc/sys/vm/drop_caches

# echo 1 can be used to clear only page caches
# Documentation here: http://www.kernel.org/doc/Documentation/sysctl/vm.txt
# Although I found it here: http://unix.stackexchange.com/questions/8398/how-to-time-grep-commands-accurately/8399#8399

