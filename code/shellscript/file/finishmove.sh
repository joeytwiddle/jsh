#!/bin/sh
## The problem with all these "removing duplicates" scripts is verify whether or not the file is the same actual file.
## On Unix confusions with symlinks can be resolved using realpath.
## But with mounted networked computers, and virtual filesystems, this will be harder to verify.
## Possible methods:
##  - Move file A to safe storage, or just rename it.  Then check if file B is still there
##  - Alter file A ...

## AKA safemv?  Could be useful when you want to copy something, and files in target may match those in source.  You almost expect it, but want to copy over any differences also, without mv -i complaining!  Or do we complain on non-identical collision?  Ah finishmove was actually made to finish a move that had broken halfway.  Maybe safemv is different?

jshwarn "TODO: could DESTFILE be a symlink to SRCFILE, overwritten badly and lost?"

SRC="$1"
DEST="$2"

if test ! "$SRC" || test ! "$DEST"
then
	echo "finishmove <srcdir> <destdir>"
	echo "moves all files in srcdir to destdir"
	# echo "NB: <destdir> must be absolute!"
	exit 1
fi

SRC=`absolutepath "$SRC"`
DEST=`absolutepath "$DEST"`

cd "$SRC" || exit 3
find . -not -type d |
while read FILE
do
	DIR=`dirname "$FILE"`
	mkdir -p "$DEST/$DIR"
	DESTFILE="$DEST/$FILE"
	if [ -e "$DESTFILE" ] || [ -f "$DESTFILE" ]
	then
		CMP=`cmp "$FILE" "$DESTFILE" 2>&1`
		if [ "$?" = 0 ]
		then
			# echo "Could delete $FILE since $DESTFILE is the same (but be sure it's not a symlink!)"
			# cksum "$FILE" "$DESTFILE"
			# ls -l "$FILE" "$DESTFILE"
			echo "Deleting $FILE"
			rm "$FILE"
			del "$FILE"
		elif [[ "$CMP" =~ "^cmp: EOF on $DESTFILE$" ]]
		then
			echo "Finishing $FILE"
			mv "$FILE" "$DESTFILE"
		fi
	else
		echo "Moving $FILE"
		mv "$FILE" "$DESTFILE"
	fi
done
