#!/bin/sh
sensors | grep '^Core [0-9]*:' | takecols 3 | sort -n | tail -n 1 | sed 's/^+\([0-9]*\)\..*$/\1/'
