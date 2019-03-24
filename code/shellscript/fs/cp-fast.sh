#!/bin/sh

# With --reflink=auto, cp will make a lightweight copy of each file when possible, which is super fast.
#
# The time and drive space cost of actually copying the files will be deferred until one of the copies actually changes (copy-on-write).
#
# This is only supported on some filesystems, e.g. btrfs.
#
# Warning: Delaying the copy until later increases the risk that you will unexpectedly run out of drive space at a future time.

exec cp -a -i --reflink=auto --sparse=always
