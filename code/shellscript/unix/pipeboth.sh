# jsh-depends: jdeltmp jgettmp
## Takes input on stdin (stdout), echos output on both stdout and stderr
## Can be useful for debugging:  Insert |pipeboth| somewhere in a chain of |s to print the state of the stream at that point to stderr, without breaking the original operation.
## pipeboth's behaviour is to output on both streams, but only accept input from the stdin (the previous stdout), not stderr.
## So if you want to pipe FROM both stdout and stderr streams of previous call, you should do:
# ... command ... 2>&1 | pipeboth | ...

# cat |

## This version is dodgy, but advantageous because it's line-buffered =)
# cat "$@" | ## Could do this, if we don't want pipeboth to take options.  Could do that anyway!
# 
# while read X
# do
	# echo "$X"
	# echo "$X" >&2
# done

TMPFILE=`jgettmp pipeboth`
cat "$@" > $TMPFILE
cat $TMPFILE >&2
cat $TMPFILE
jdeltmp $TMPFILE
