#!/bin/sh
# Skips N lines from the end of a stream
## See also: tail -n +5

# jsh-depends: countlines jgettmp

TF=`jgettmp $$`
NUMLINES=`tee "$TF" | countlines`
KEEPLINES=`expr $NUMLINES - $1`
cat "$TF" | head -n "$KEEPLINES"
