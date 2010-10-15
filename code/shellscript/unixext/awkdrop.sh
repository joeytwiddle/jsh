#!/bin/sh
LINES="$1"
shift

awk ' { if ( NR > '$LINES' ) { print $LN } } ' "$@"
