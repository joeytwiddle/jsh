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
				echo "Note: there were $# files left to undel."
				exit 1
			fi
		fi
		# fi
		DEST="./$1"
		if test -f "$DEST"; then
			echo "del: File $DEST already exists!"
			exit 1
		fi
		mv "$DELEDFILE" "$DEST"
		echo "./$DEST <- $DELEDFILE"
		shift
	done
fi
