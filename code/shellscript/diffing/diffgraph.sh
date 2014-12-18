#!/bin/bash

## TODO: Optionally, instead of showing 0 for closest, mark X as duplicates found, and list distance to non-0 neighbour (distance from rest of graph).

## Diffs each file in a bunch of files against every other to find which files
#  are most similar.  Finally produces a graph showing relations between files.

## Exponential by number of arguments!!
## Consider using a size-difference heuristic to skip diffs which will never beat current best

## This script also serves to demonstrate setting variables in a loop.
#  It seems that the pipe in
#    printf "%s" "$FILES" | while read X; do
#  invokes a new sh and hence variables are forgotten,
#  whereas the
#    for X in $FILES; do
#  remembers vars set inside once it's finished.  =)

## Note:
#  Sometimes we might need to go for say the n'th best in order to make the
#  graph "complete" (all joined, no islands).

if [ ! "$1" ] || [ "$1" = --help ]
then
	echo
	echo "diffgraph [ -fine | -diffcom <command> ] <files>..."
	echo
	echo "  calculates weightings to show which files are similar to each other."
	echo
	echo "  Each file is diffed against every other using the command provided (diff by"
	echo "  default), and the closeness of two files is judged by the size of their diff."
	echo
	echo "  If read/plotted properly, this shows which files forked from which others."
	echo
	echo "  For better alignment, you may like to pass through columnise-clever:"
	echo
	echo "    diffgraph file.ext.* | columnise-clever -only '^[^ ]* [^ ]* '"
	echo
	exit 1
fi

if [ "$1" = -fine ]
then DIFFCOM=worddiff; shift
fi

## TODO: jsh should have policy for whether envvar or -option takes priority in presence of both.
if [ "$1" = -diffcom ]
then
	DIFFCOM="$2"
	shift; shift
fi
if [ ! "$DIFFCOM" ]
then DIFFCOM="diff -a" ## -a accepts binary files for diffing
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
for X in "$@"
do
	BESTFORX="none_found"
	BESTFORXSIZE="999999999"
	# printf "%s" "$FILES" |
	for Y in "$@"
	do
		if [ ! "$X" = "$Y" ]
		then
			# echo "Testing: $X $Y" >&2
			## Diff the files, and find size of diff:
			# DIFFFILE=$DIFFDIR/"$X"____"$Y" ## No good if $Y contains a '/' !

			## This creates a file (slow/inefficient/waste-space):
			# DIFFFILE=`jgettmp diffgraph..."$X"..."$Y"`
			# $DIFFCOM "$X" "$Y" > "$DIFFFILE"
			# RESULTSIZE=`filesize "$DIFFFILE"`
			# jdeltmp $DIFFFILE

			## This just measures the length of the diff (fast,efficient):
			# RESULTSIZE=` $DIFFCOM "$X" "$Y" | countbytes `

			## Extra support for fine worddiffs, to make the numbers nicer (smaller):
			## TODO CONSIDER: should we gzip all diifs (not just fine ones/ones done with worddiff) before counting length?
			if [ "$DIFFCOM" = worddiff ]
			then
				RESULTSIZE=` $DIFFCOM "$X" "$Y" | gzip -c | countbytes `
			else
				RESULTSIZE=` $DIFFCOM "$X" "$Y" | countbytes `
			fi

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
	## what symbol for derivation?  <-   >-  <<<  ++--  
	echo "$X" ">-($BESTFORXSIZE)<-	" $BESTFORX
	# echo "$BESTFORX	($BESTFORXSIZE)->	$X"
done |

cat
# columnise

jdeltmp $DIFFDIR
