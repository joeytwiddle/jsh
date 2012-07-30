#!/bin/sh
## Returns the given arguments as a string, with each arg quoted and with any
## quotes inside it escaped.  Useful when you are forced to pass multiple
## arguments in one string, and the arguments might contains spaces or other
## evil chars!
for arg
do
	escapedArg=$(printf "%s" "$arg" | sed 's+"+\\"+g')
	printf "\"%s\" " "${escapedArg}"
done | sed 's+ $++'
