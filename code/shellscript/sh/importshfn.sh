# . importshfn <jtoolname> | <shellscript> ...

## TODO: optionally grep the script for potential problems (as bughunt clues for developer)
##       eg. exit will only be rarely desirable, mostly that should become a return
##       maybe jsh scripts which are ready to be used as functions should say so (meta)

# Warning: incomptabile scripts can entirely kill your shell!
# Actually maybe that's just sourced scripts which have an exit in them.

## TODO: If the function is already loaded, don't re-load it (eg. ungrep imports itself)

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
