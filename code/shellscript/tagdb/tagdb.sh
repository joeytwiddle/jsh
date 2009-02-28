[ "$TAGDBDIR" ] || TAGDBDIR="$HOME/.tagdb"

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
	cat "$KEYFILE" 2>/dev/null

else

	echo "tagdb set <key> <value>"
	echo "tagdb get <key>"

fi

