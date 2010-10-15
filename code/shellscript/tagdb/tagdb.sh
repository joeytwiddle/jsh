## TODO: On Unix filesystems, symlinks are more efficient than file contents
## for storing small strings.  But presumably we can't store all chars in
## symlinks, e.g. "\n"?  Maybe we should switch between symlink and file as and
## when needed, and check which type when reading...

## TODO: tagdb addtag "tag://robots" "file://mnt/hda2/stuff/mp3s/wipeout/Wipeout OSTs/Wipeout Pulse/02 Steady Rush.mp3"
##       We should add tag:// automatically?
## BUG TODO: tag:// does not work in that the /s get lost - we need to encode
##           them, or stop storing the data on a filesystem :P

[ "$TAGDBDIR" ] || TAGDBDIR="$HOME/.tagdb"

showhelp() {

cat << !

Usage:

  tagdb set <key> <value>
  tagdb get <key>
  tagdb addtag <tag> <item_name>

  tagdb addfile <file>   - Adds all the dirs in the file's path as tags to that
                           file

  tagdb addtolistonce <list_key> <value>

  tagdb listdb

!

}

## TODO BUGS: If KEY contains a . we could end up with $TAGDBDIR/d/o/t/=/./.data where the /./ is wrong!
getfilefromkey() {
	KEYFILE="$TAGDBDIR"/"`echo "$KEY" | sed 's+\(...\)+\1/+g'`".data
	KEYDIR="`dirname "$KEYFILE"`"
	[ -d "$KEYDIR" ] || verbosely mkdir -p "$KEYDIR"
}

case "$1" in

	set)

		KEY="$2"
		VALUE="$3"
		getfilefromkey

		## jshinfo "KEYFILE=$KEYFILE"
		jshinfo "$KEYFILE <- \"$VALUE\""
		echo "$VALUE" > "$KEYFILE"

	;;

	get)

		KEY="$2"

		getfilefromkey
		jshinfo "$KEYFILE = \"$VALUE\""
		# VALUE="`cat "$KEYFILE" 2>/dev/null`"
		# echo "$VALUE"
		touch "$KEYFILE" ; cat "$KEYFILE"

	;;

	addfile)

		FILE="$2"
		# FILE=`realpath "$FILE"`

		FILENAME="`filename "$FILE"`"
		echo "$FILE" | beforelast / | tr '/' '\n' |
		while read DIRBIT
		do tagdb addtag "$DIRBIT" "filename=$FILENAME"
		done

	;;

	addtag)

		tagdb addtolistonce "$2".TAG "$3" # ... ?
		
	;;

	addtolistonce)

		KEY="$2"
		VALUE="$3"
		getfilefromkey

		VALUERE="`toregexp "$VALUE"`"
		( touch "$KEYFILE" ; cat "$KEYFILE" | grep -v "^$VALUERE$"; echo "$VALUE" ) | dog "$KEYFILE"
		jshinfo "Added \"$VALUE\" to $KEYFILE"

	;;

	listdb)

		( cd "$TAGDBDIR" && find . -type f ) | afterfirst "^./" | sed 's+\.data$++' | tr -d / | highlight =

	;;

	*)

		showhelp

		[ "$1" == --help ] ; exit

	;;

esac

