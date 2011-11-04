#!/bin/sh

# jsh-help: Skips N lines from the front of a stream.
# jsh-help: Note: awkdrop is recommended for speed.
# jsh-help: See also: head -n -10
# jsh-help: See also: sed 1d

## TODO: I think a recent change may have caused drop to behave as such:
##       drop 20 on a 10 line file blocks for 10 lines of input...?!

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
		read LINE || exit 0 ## DONE: If we are out of lines, give up!  Fixes bug of this getting caught looping forever.
		N=$(($N-1));
	done

	## TODO: this might fail if we only just read the very last line.
	cat

}
