#!/bin/bash

## Diffs each file in a bunch of files against every other to find which files
#  are most similar.  Finally produces a graph showing relations between files.

## Exponential by number of arguments!!
## Considuer using size-difference heuristic to skip diffs which will never beat current best

## This script also serves to demonstrate setting variables in a loop.
#  It seems that the pipe in
#    printf "%s" "$FILES" | while read
#  invokes a new sh and hence variables are forgotten.

## Note:
#  Sometimes we might need to go for say the n'th best in order to make the
#  graph "complete" (all joined, no islands).

if [ ! "$1" ] || [ "$1" = --help ]
then
	echo
	echo "diffgraph [ -diffcom <command> ] <files>..."
	echo
	echo "  constructs a graph showing which files are similar to each other."
	echo "  Each file is diffed against every other using the command provided (diff by"
	echo "  default), and the closeness of two files is judged by the size of their diff."
	echo
	exit 1
fi

## TODO: jsh should have policy for whether envvar or -option takes priority in presence of both.
if [ "$1" = -diffcom ]
then
	DIFFCOM="$2"
	shift; shift
fi
if [ ! "$DIFFCOM" ]
then DIFFCOM=diff
# then DIFFCOM=worddiff
fi

NL="
"

# FILES=""
# for X
# do FILES="$FILES$X$NL"
# done

DIFFDIR=`jgettmpdir diffgraph`

# printf "%s" "$FILES" |
for X
do
	BESTFORX="none_found"
	BESTFORXSIZE="999999999"
	# printf "%s" "$FILES" |
	for Y
	do
		if test ! "$X" = "$Y" ## output would be empty anyway
		then
			# echo "Testing: $X $Y"
			## Diff the files, and find size of diff:
			# DIFFFILE=$DIFFDIR/"$X"____"$Y" ## No good if $Y contains a '/' !
			DIFFFILE=`jgettmp diffgraph___"$X"___"$Y"`
			$DIFFCOM "$X" "$Y" > "$DIFFFILE"
			RESULTSIZE=`filesize "$DIFFFILE"`
			jdeltmp $DIFFFILE
			## See if size beats or matches best so far:
			test "$RESULTSIZE" = "$BESTFORXSIZE" &&
			BESTFORX="$BESTFORX$NL$Y" ||
			if test "$RESULTSIZE" -lt "$BESTFORXSIZE"
			then
				BESTFORX="$Y"
				BESTFORXSIZE="$RESULTSIZE"
				# echo "Improvement: $X and $Y differ by $RESULTSIZE"
			fi
			debug "Got $RESULTSIZE Diffing $X against $Y."
		fi
	done
	# echo "$X is closest to $BESTFORX (at $BESTFORXSIZE bytes)"
	echo "$X" "<-($BESTFORXSIZE)" $BESTFORX
	# echo "$BESTFORX	($BESTFORXSIZE)->	$X"
done |

cat
# columnise

jdeltmp $DIFFDIR
