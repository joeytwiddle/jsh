#!/bin/sh
# Note: rtag seems more sensible so use that in future

if test "$1" = "" || test "$2" = ""; then
	echo "cvsbranch ( make | get ) <tagname>"
	exit 1
fi

TAGNAME="$2"

# This should be contains
# if ! endswith "$TAGNAME" "branch"; then
	# echo "Changing your tag name to:"
	# TAGNAME="$TAGNAME""branch"
	# echo "$TAGNAME"
# fi

case "$1" in

	make)

		# Tag all the files to specify the branch
		cvs -q tag -c -R -b "$TAGNAME" ||
			echo "There were problems creating tag." && exit 1

		# Update current working version to the branch
		# This is dodgy if you have made modifications:
		# they will be merged in.
		cvsupdate -r "$TAGNAME"
		
	;;

	get)
		cvsupdate -r "$TAGNAME"
	;;

	*)
		echo "Invalid option: $1"
	;;
	
esac
