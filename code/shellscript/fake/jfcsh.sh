# Does a simple one-way jfc diff

case "$1" in
	""|-h|--help)
		echo "jfcsh [ -bothways | -common ] <file_A> <file_B>"
		echo "  will show lines in file_A which are not in file_B."
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
