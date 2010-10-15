#!/bin/sh
A="$1"
B="$2"
TMPA=`jgettmp "$A"`
TMPB=`jgettmp "$B"`
cat "$A" | sort > "$TMPA"
cat "$B" | sort > "$TMPB"
vimdiff "$TMPA" "$TMPB"
wait
jdeltmp "$TMPA" "$TMPB"
