#!/bin/sh

## Takes input on stdin, echos output on both stdout and stderr.
## Can be useful for debugging.  Insert |pipeboth| somewhere in a chain of |s to print the state of the stream at that point to stderr, without breaking the original operation.
## For example, when debugging the following command, if you want to check if the output from c is what you expected, then do:
##   a | b | c | pipeboth | d | e | f

## pipeboth's behaviour is to output on both streams, but bash only allows it to accept input from the stdin (the previous stdout), not stderr.
## So if you want to pipe FROM both stdout and stderr streams of previous call, you should do:
# ... command ... 2>&1 | pipeboth | ...

## Alternatives: you could: tee -a /dev/stderr

# [ "$1" = --line-buffered ] && shift
tee /dev/stderr
exit



## OLD IMPLEMENTATIONS
# OLD jsh-depends: jdeltmp jgettmp

# cat |

if [ "$1" = --line-buffered ]
then

	## This version might be dodgy (e.g. if non-ASCII chars are read?),
	## but for txt streams, advantages are: it's line-buffered, and it doesn't use a tempfile.
	shift
	cat "$@" |
	while IFS='' read X
	do
		# echo "$X"
		# echo "$X" >&2
		printf "%s\n" "$X"
		printf "%s\n" "$X" >&2
	done

else

	TMPFILE=`jgettmp pipeboth`
	cat "$@" > $TMPFILE
	cat $TMPFILE >&2
	cat $TMPFILE
	jdeltmp $TMPFILE

fi
