## TODO: On Unix filesystems, symlinks are more efficient than file contents
## for storing small strings.  But presumably we can't store all chars in
## symlinks, e.g. "\n"?  Maybe we should switch between symlink and file as and
## when needed, and check which type when reading...

[ "$TAGDBDIR" ] || TAGDBDIR="$HOME/.tagdb"

## TODO BUGS: If KEY contains a . we could end up with $TAGDBDIR/d/o/t/=/./.data where the /./ is wrong!
getfilefromkey() {
	KEYFILE="$TAGDBDIR"/"`echo "$KEY" | sed 's+\(...\)+\1/+g'`".data
	KEYDIR="`dirname "$KEYFILE"`"
	[ -d "$KEYDIR" ] || verbosely mkdir -p "$KEYDIR"
}

if [ "$1" = set ]
then

	KEY="$2"
	VALUE="$3"
	getfilefromkey

	## jshinfo "KEYFILE=$KEYFILE"
	jshinfo "$KEYFILE <- \"$VALUE\""
	echo "$VALUE" > "$KEYFILE"

elif [ "$1" = get ]
then

	KEY="$2"

	getfilefromkey
	jshinfo "$KEYFILE = \"$VALUE\""
	# VALUE="`cat "$KEYFILE" 2>/dev/null`"
	# echo "$VALUE"
	touch "$KEYFILE" ; cat "$KEYFILE"

elif [ "$1" = addfile ]
then

	FILE="$2"

	FILENAME="`filename "$FILE"`"
	echo "$FILE" | beforelast / | tr '/' '\n' |
	while read DIRBIT
	do tagdb addtolistonce "tag=$DIRBIT" "filename=$FILENAME"
	done

elif [ "$1" = addtolistonce ]
then

	KEY="$2"
	VALUE="$3"
	getfilefromkey

	VALUERE="`toregexp "$VALUE"`"
	( touch "$KEYFILE" ; cat "$KEYFILE" | grep -v "^$VALUERE$"; echo "$VALUE" ) | dog "$KEYFILE"
	jshinfo "Added \"$VALUE\" to $KEYFILE"

else

	echo "tagdb set <key> <value>"
	echo "tagdb get <key>"
	echo "tagdb addfile <file>"
	echo "tagdb addtolistonce <list_key> <value>"

fi

