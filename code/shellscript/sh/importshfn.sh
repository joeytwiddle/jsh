# . importshfn <jtoolname> | <shellscript> ...
# Warning: incomptabile scripts can entirely kill your shell!

for SCRIPT
do

	# Find the script
	LOCATION="$JPATH/tools/$SCRIPT"
	if test ! -f "$LOCATION"; then
		LOCATION="$SCRIPT"
		if test ! -f "$LOCATION"; then
			LOCATION=""
		fi
	fi

	if test "$LOCATION" = ""; then

		echo "importshfn: no such script: $SCRIPT" > /dev/stderr

	else

		# Import it

		TMPFILE=`jgettmp`

		makeshfunction "$LOCATION" > $TMPFILE

		. $TMPFILE

		jdeltmp $TMPFILE

	fi

done
