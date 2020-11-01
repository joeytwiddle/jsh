#!/bin/sh
HOWMUCH="$1"
if [ -z "$HOWMUCH" ]
then HOWMUCH=7
fi

adjustvolumeby -"$HOWMUCH"
