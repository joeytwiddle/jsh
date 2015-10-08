#!/bin/sh
HOWMUCH="$1"
if [ -z "$HOWMUCH" ]
then HOWMUCH=10
fi

adjustvolumeby -"$HOWMUCH"
