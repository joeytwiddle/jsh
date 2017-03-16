#!/bin/sh

if [ -n "$1" ]
then
	numcols="$1"
	shift
else
	#numcols="$COLUMNS"
	numcols="$(tput cols)"
fi

cut -c 1-"${numcols}" "$@"
