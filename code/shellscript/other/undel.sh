#!/bin/sh

## TODO: Should now also consider /RECLAIM directory of partition, to reflect new del.
## DONE: for "$1" = "" but not otherwise.

TRASHDIR="$JPATH/trash"
if test ! -w "$JPATH/trash"
then TRASHDIR=`dirname "\`jgettmp\`"`/trash
fi

## Better than PWD, but still this needs to update wrt. del's new changes.
DIR=`realpath "$PWD"`

if [ "$1" = "" ]
then

	## Old style deleting to $JPATH/trash:

	if [ -d "$TRASHDIR/$DIR" ]
	then
		echo "Deleted files in `#cursegreen`$TRASHDIR/$DIR/`#cursenorm`:"
		ls -l -ArtFh --color "$TRASHDIR/$DIR"
	fi

	## New style deleting to /RECLAIM

	MOUNTPNT=`wheremounted .`
	TRASHDIR="$MOUNTPNT/RECLAIM"
	if [ -d "$TRASHDIR" ]
	then
		FINALPATH=$TRASHDIR/`realpath . | sed "s+$MOUNTPNT++"`
		echo "Deleted files in `#cursegreen`$FINALPATH`#cursenorm`:"
		ls -l -ArtFh --color "$FINALPATH"
	fi

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
				error "(should be warning) undel needs updating to deal with RECLAIM directories; but what you could try is deleting a dummy and watching where it goes, then looking there for the thing you were after."
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
