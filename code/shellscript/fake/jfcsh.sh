# Does a simple one-way jfc diff

## TODO: jfc / jfcsh bridge (has been tried somewhere...)

case "$1" in
	""|-h|--help)
		echo "jfcsh [ -bothways | -common ] <file_A> <file_B>"
		echo "  will show lines in file_A which are not in file_B."
		echo "  NOTE: syntax is likely to change as jfcsh becomes a standin for binary jfc."
		echo "        Main difference in change is the verbose output of jfc."
		exit 1
	;;
esac

BOTHWAYS=
COMMON=
while true; do
	if test "$1" = "-bothways"; then
		BOTHWAYS=true
	elif test "$1" = "-common"; then
		COMMON=true
	else
		break
	fi
	shift
done

if test $COMMON; then

		cat "$1" |
		while read X; do
			grep "^$X$" "$2"
		done

else

	## I used to do this very inefficiently by grepping $2 once for each line in $1!
	## Now instead I first sort the files, then GNU diff them, and extract from that.
	## Note: This gives a slightly different output.  Now all extra lines are shown,
	## including duplicates, wheras before only unique lines were shown.

	A=`jgettmp "$1"`
	B=`jgettmp "$2"`

	cat "$1" | sort > "$A"
	cat "$2" | sort > "$B"

	test $BOTHWAYS && (
		cursecyan
		centralise -pad "v" " " "v" "Lines only in $A"
		cursenorm
		echo
	)

	diff "$A" "$B" |
		grep "^< " | sed "s/^< //"

	test $BOTHWAYS && (

		cursecyan
		centralise -pad "-" "-" "-" ""
		cursenorm
		echo

		diff "$B" "$A" |
			grep "^< " | sed "s/^< //"

		## Or:
		# diff "$A" "$B" |
			# grep "^> " | sed "s/^> //"

		cursecyan
		centralise -pad "^" " " "^" "Lines only in $B"
		cursenorm
		echo

	)

	jdeltmp $A
	jdeltmp $B

fi
