#!/bin/sh
sensors | grep '^temp1:' | takecols 2 | sort -n | tail -n 1 | sed 's/^+\([0-9]*\)\..*$/\1/'
