#!/bin/sh

# When Linux gets low on memory, earlyoom kills some Chrome tabs for me
# When Mac OS X gets low on memory, we can kill some Chrome tabs using this script

wotgobblemem | grep "Google Chrome Helper" | takecols 3 | tail -n 10 | withalldo kill
