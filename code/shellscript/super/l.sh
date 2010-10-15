#!/bin/sh

## useless_unless_sourced
ls -lartFh --color "$@"

# if [ "$1" = "$PWD" ]
# then :
# else
	# if [ "$1" ] && [ ! "$1" = . ] && [ -d "$1" ]
	# then
		# echo cd \"$1\" >&2
		# cd "$*"
	# else
		# PDIR=`dirname "$1" 2>/dev/null` ## if error, then PDIR = . which is acceptable
		# if [ ! "$PDIR" = . ] && [ -d "$PDIR" ]
		# then
			# echo cd \"$PDIR\" >&2
			# cd "$PDIR"
		# fi
	# fi
# fi

