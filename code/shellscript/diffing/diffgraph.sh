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

NL="
"

if test "$DIFFCOM" = ""
then DIFFCOM=diff
# then DIFFCOM=worddiff
fi

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
		fi
	done
	# echo "$X is closest to $BESTFORX (at $BESTFORXSIZE bytes)"
	echo "$X" "<-($BESTFORXSIZE)" $BESTFORX
	# echo "$BESTFORX	($BESTFORXSIZE)->	$X"
done | columnise

jdeltmp $DIFFDIR
