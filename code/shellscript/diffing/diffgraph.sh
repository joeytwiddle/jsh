#!/bin/bash

## This script also serves to demonstrate setting variables in a loop.
#  It seems that the pipe in
#    printf "%s" "$FILES" | while read
#  invokes a new sh and hence variables are forgotten.

# FILES=""
# for X
# do FILES="$FILES$X
# "
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
		echo "test $X $Y"
		if test ! "$X" = "$Y"
		## output would be empty anyway
		then
			DIFFFILE=$DIFFDIR/"$X"____"$Y"
			diff "$X" "$Y" > "$DIFFFILE"
			RESULTSIZE=`filesize "$DIFFFILE"`
			if test "$RESULTSIZE" -lt "$BESTFORXSIZE"
			then
				BESTFORX="$Y"
				BESTFORXSIZE="$RESULTSIZE"
				echo "$X and $Y differ by $RESULTSIZE"
			fi
		fi
	done
	echo "$X is closest to $BESTFORX (at $BESTFORXSIZE bytes)"
done
