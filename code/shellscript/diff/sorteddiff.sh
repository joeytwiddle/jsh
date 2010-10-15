#!/bin/sh
FILEA="$1"
FILEB="$2"

TMPA=`jgettmp "$FILEA"`
TMPB=`jgettmp "$FILEB"`
shift
shift

cat "$FILEA" | sort > "$TMPA"
cat "$FILEB" | sort > "$TMPB"

diff "$TMPA" "$TMPB" "$@"

jdeltmp "$TMPA" "$TMPB"
