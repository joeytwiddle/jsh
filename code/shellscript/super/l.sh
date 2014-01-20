#!/bin/sh

## I know 'l' should really be an alias, but I personally like to use it e.g.
## from within vim.

# Not needed if we have installed coreutils on PATH :)
#JSH_OSNAME=`uname -s`
#if [ "$JSH_OSNAME" = Darwin ]
#then color_args="-G"
#elif [ "$JSH_OSNAME" = Linux ]
#then color_args="--color"
#fi

# We could check with: ls --version 2>&1 | grep 'GNU coreutils'
# but this is somewhat overhead.  Perhaps jsh should do this at startup, and export a var.
# In this case when certain scripts (or groups of scripts) need something preloaded we could make: $JPATH/preload/l
# This might make it easier to drop the related preloads when a script or group of scripts are unwanted and removed.

# For GNU ls:
color_args="--color"

## useless_unless_sourced
ls -lartFh $color_args "$@"

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

