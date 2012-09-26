# jsh-ext-depends-ignore: script
# jsh-depends: makeshfunction jdeltmp jgettmp
## Usage:
## . importshfn <jshtool> | <path_to_shellscript> ...

## TODO: optionally grep the script for potential problems (as bughunt clues for developer)
##       eg. exit will only be rarely desirable, mostly that should become a return
##       maybe jsh scripts which are ready to be used as functions should say so (meta)

# Warning: Using this on unsuitable scripts can do terrible things!
# For example if a sourced script uses 'exit' and it is not successfully
# converted to 'return' then it may cause you to drop out of your shell,
# perhaps closing your terminal app.

## TODO: If the function is already loaded, don't re-load it (eg. ungrep imports itself)
## TODO: Cache the output of makeshfunction so we don't have to call it every time.
##       Yes it is hard to know when a cached copy is invalidated (e.g. by
##       child dependencies) but that is a developer issue - end users don't
##       change anything and want imports to happen quickly!
## Develops could export JSH_IMPORT_NOCACHE, or run clearshfncache?

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

		# memo -f "$LOCATION"
		makeshfunction "$LOCATION" > $TMPFILE

		. $TMPFILE

		jdeltmp $TMPFILE

	fi

done
