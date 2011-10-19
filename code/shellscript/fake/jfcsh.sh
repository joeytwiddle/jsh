#!/bin/sh
## Does a simple one-way jfc diff
## See also: comm
# jsh-depends: cursecyan centralise cursenorm jdeltmp jgettmp
## TODO: jfc / jfcsh bridge (has been tried somewhere...)
## See other implementations: http://mywiki.wooledge.org/BashFAQ/036

case "$1" in
	""|-h|--help)
		echo
		echo "jfcsh [ -bothways | -common ] [ -sorted ] <file_A> <file_B>"
		echo
		echo "  will show lines in file_A which are not in file_B."
		echo
		echo "    -bothways: also shows lines in file_B not in file_A, verbosely for user"
		echo "    -common: instead, show lines which are in both file_A and file_B"
		echo "    -sorted: for efficiency, jfcsh may assume files are already sorted"
		echo
		echo "  NOTE: Syntax may change as jfcsh becomes a standin for binary jfc."
		echo "        But preferably a bridge-wrapper will be used, to retain syntax."
		echo "        The main difference is the verbose output of jfc."
		echo "        Is it ever useful for jfc to stand in for jfcsh (now it uses diff is it always fast)?"
		echo
		exit 1
	;;
esac

BOTHWAYS=
COMMON=
SORT=sort
while true; do
	if test "$1" = "-bothways"; then
		BOTHWAYS=true
	elif test "$1" = "-common"; then
		COMMON=true
	elif test "$1" = "-sorted"; then
		SORT=cat
	else
		break
	fi
	shift
done

if [ "$COMMON" ]
then

		cat "$1" |
		while IFS="" read X
		do
			X="`toregexp "$X"`"
			grep "^$X$" "$2"
		done

else

	## I used to do this very inefficiently by grepping $2 once for each line in $1!
	## Now instead I first sort the files, then GNU diff them, and extract from that.
	## Note: This gives a slightly different output.  Now all "unpaired" lines are shown,
	## including unpaired duplicates of already matched lines, wheras before
	## only unique lines were shown.

	## jgettmp causes a huge number of forks (~32)!  I shaved this down to 28.
	# A=`jgettmp "$1"`
	# B=`jgettmp "$2"`
	A="$1.jfcsh_sorted"
	B="$2.jfcsh_sorted"

	$SORT "$1" > "$A"
	$SORT "$2" > "$B"

	if [ "$BOTHWAYS" ]
	then
		cursecyan
		centralise -pad "v" " " "v" "Lines only in $1"
		cursenorm
		echo
	fi

	diff "$A" "$B" |
		grep "^< " | sed "s/^< //"

	if [ "$BOTHWAYS" ]
	then

		cursecyan
		centralise -pad "-" "-" "-" ""
		cursenorm
		echo

		diff "$B" "$A" |
			grep "^< " | sed "s/^< //"

		## Or equivalently:
		# diff $A $B |
			# grep "^> " | sed "s/^> //"

		cursecyan
		centralise -pad "^" " " "^" "Lines only in $2"
		cursenorm
		echo

	fi

	# jdeltmp $A
	# jdeltmp $B
	rm -f "$A" "$B"

fi
