#!/bin/sh

# Strangely, betweenthe implies there are >2 "$@"s
# and the output should be multiple answers, on consecutive lines

#sed "s/\n/\\\n/g" | tr "$@" "\n"
sed "s+$*+\n+g"
