#!/bin/sh
FILENAME="$1"
SIZEINMEGS="$2"
[ "$FILENAME" ] && [ "$SIZEINMEGS" ] || exit 1

dd if=/dev/zero of="$FILENAME" count="$SIZEINMEGS" ibs=1048576 obs=1048576

if [ "$MAKESPARSE" ]
then
	cp --sparse=always "$FILENAME" "$FILENAME".sparse
	du -sk "$FILENAME" "$FILENAME.sparse"
fi
