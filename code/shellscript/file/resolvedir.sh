#!/bin/sh
# jsh-ext-depends: basename dirname

## An implementation of realpath(1,3) in sh.
## Finds absolute path of given filename (by following all symlinks in path, from leaf to root).

## Differences from realpath:
##   Does not error + fail if file does not exist.
##   Does not deal with ".."s, just leaves them.

# jsh-depends: absolutepath isabsolutepath justlinks filename

if [ "$1" = -showprogress ]
then SHOWPROG=true ; shift
fi

## X is todo, Y is done

X=`absolutepath "$1"`
Y=""

while [ ! "$X" = "/" ] && [ ! "$X" = "." ]
do
	C=`basename "$X"`
	L=`justlinks "$X"`
	X=`dirname "$X"`
	if [ "$L" ] ## link exists
	then
		## expand it
		[ "$SHOWPROG" ] && echo "$X/`cursegreen;cursemagenta`$C`cursenorm` -> $L"
		if isabsolutepath "$L"
		then X="$L" ## absolute link
		else X="$X/$L" ## relative link
		fi
	else
		[ "$SHOWPROG" ] && echo "$X/ `cursegreen`$C`cursenorm` $Y"
		Y="/$C$Y" ## continue
	fi
done

[ "$Y" ] || Y="/"
echo "$Y"
