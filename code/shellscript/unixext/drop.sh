#!/bin/sh
## TODO: I think a recent change may have caused drop to behave as such:
##       drop 20 on a 10 line file blocks for 10 lines of input...?!

# Skips N lines from the front of a stream.
# Note: awkdrop is recommended for speed.

## TODO: echo (and even printf) can muck up lines with adjacent spaces!
##       deprecate this method, in favour of some other, eg. awkdrop.

N="$1"
shift

cat "$@" |

{

	while true
	do
		if [ "$N" = 0 ]
		then break
		fi
		read LINE
		N=$(($N-1));
	done

	cat

}
