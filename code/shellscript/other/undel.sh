#!/bin/sh

## Should now also consider /RECLAIM directory of partition, to reflect new del.

TRASHDIR="$JPATH/trash"
if test ! -w "$JPATH/trash"
then TRASHDIR=`dirname "\`jgettmp\`"`/trash
fi

## Better than PWD, but still this needs to update wrt. del's new changes.
DIR=`realpath "$PWD"`

if [ "$1" = "" ]
then
	echo "Deleted files in `#cursegreen`$TRASHDIR/$DIR/`#cursenorm`:"
	ls -ArtFh --color $TRASHDIR/$DIR
else
	while [ ! "$1" = "" ]
	do
		DELEDFILE="$TRASHDIR/$DIR/$1"
		# Problem is: may be a broken symlink that will fix on undeletion
		# # May not be compatible with Unix:
		# if test ! -e "$DELEDFILE"; then
		if [ ! -f "$DELEDFILE" ]
		then
			if [ ! -d "$DELEDFILE" ]
			then
				echo "Sorry - $DELEDFILE is neither a file or directory."
				echo "Try one of these ..."
				find $TRASHDIR -name "$1"
				echo "Note: there were $# files left to undel."
				exit 1
			fi
		fi
		# fi
		DEST="./$1"
		if [ -f "$DEST" ]
		then
			echo "del: File $DEST already exists!"
			exit 1
		fi
		mv "$DELEDFILE" "$DEST"
		echo "$DEST "`cursegreen`"<-"`cursenorm`" $DELEDFILE"
		shift
	done
fi
