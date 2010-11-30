#!/bin/bash
## Unlike linkhome (and stow), never links to dirs, always creates its own full dir tree.

## BUG: does not follow symlinks in the target though, so symlinks which are actually links to dirs are linked not built.

function dodirs () {
	( cd "$SOURCE" && find . -type d -mindepth 1 ) | ## mindepth 1 avoids "./"
	$REVERSE |
	while read DIR
	do
		echo "linktree: $DIRACTION \"$DEST/$DIR\""
		$DIRACTION "$DEST"/"$DIR" || $ONERROR
	done
}

function dofiles () {
	( cd "$SOURCE" && find . -not -type d ) |
	while read FILE
	do $FILEACTION "$FILE" || $ONERROR
	done
}

linkfile () {
	echo "linktree: ln -s \"$SOURCE/$FILE\" \"$DEST/$FILE\""
	ln -s "$SOURCE"/"$FILE" "$DEST"/"$FILE"
}

rmiflink () {
	if [ -L "$DEST"/"$FILE" ]
	then
		echo "linktree: rm \"$DEST/$FILE\""
		rm "$DEST"/"$FILE"
	else
		jshwarn "linktree: expected symlink: $DEST/$FILE"
	fi
}

if [ "$1" = -unlink ]
then UNLINK=true; shift
fi

SOURCE="$1"
DEST="$2"
[ "$DEST" ] || DEST=.

if [ "$UNLINK" ]
then
	DIRACTION=rmdir
	FILEACTION=rmiflink
	ONERROR=true
	REVERSE=reverse
	dofiles
	dodirs
else
	DIRACTION="mkdir -p"
	FILEACTION=linkfile
	ONERROR=exit
	REVERSE=cat
	dodirs
	dofiles
fi
