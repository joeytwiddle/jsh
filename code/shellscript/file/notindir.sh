#!/bin/bash
# because we change a variable inside while loop

# Intended as supplement to find:
# eg. find . <-condition>.. | notindir <dir>..

GREPEXPR="\("
while test ! "$1" = ""
do
	GREPEXPR="$GREPEXPR/$1/"
	shift
	test "$1" = "" ||
	GREPEXPR="$GREPEXPR\|"
done
GREPEXPR="$GREPEXPR\)"

grep -v "$GREPEXPR"

## Recursive version:
# 
# . importshfn notindir
# 
# if test ! "$*" = ""; then
	# X="$1"
	# shift
	# grep -v "/$X/" | notindir "$@"
# else
	# cat
# fi
