#!/bin/sh
if test "$1" = ""; then
	ls -F $JPATH/trash/$PWD
else
	while test ! "$1" = ""; do
		DELEDFILE="$JPATH/trash/$PWD/$1"
		# Problem is: may be a broken symlink that will fix on undeletion
		# # May not be compatible with Unix:
		# if test ! -e "$DELEDFILE"; then
		if test ! -f "$DELEDFILE"; then
			if test ! -d "$DELEDFILE"; then
				echo "Sorry - $DELEDFILE is neither a file or directory."
				echo "Try one of these ..."
				find $JPATH/trash -name "$1"
				exit 1
			fi
		fi
		# fi
		DEST="./$1"
		mv "$DELEDFILE" "$DEST"
		echo "./$DEST <- $DELEDFILE"
		shift
	done
fi
