if test "$3" = ""; then
	echo 'sedreplace <options> "search_string" "replace_string" <filename>...'
	echo "  where <options> ="
	echo "    -nobackup : do not create backup in <filename>.b4sr"
	# currently doesn't actually show # of changes
	echo "    -changes : shows files for which no changes were made."
	exit 1
fi

DOBACKUP=true
if test "$1" = "-nobackup"; then
	shift
	DOBACKUP=
fi
SHOWCHANGES=true
if test "$1" = "-changes"; then
	shift
	SHOWCHANGES=
fi
FROM="$1"
TO="$2"
shift
shift

TMPFILE=`jgettmp sedreplace$$`

for FILE do
	if test ! -w "$FILE"; then
		## Apparently /dev/stderr is not always writeable
		echo "sedreplace: $FILE not writeable" >&2
		break
	fi
	cat "$FILE" | sed "s$FROM$TOg" > "$TMPFILE"
	chmod --reference="$FILE" "$TMPFILE"
	# Shouldn't I be checking for SHOWCHANGES here?
	if cmp "$FILE" "$TMPFILE" >&2; then
		test $SHOWCHANGES && echo "sedreplace: no changes made to $FILE" >&2
	else
		if test $DOBACKUP; then
			mv "$FILE" "$FILE.b4sr" ||
			if test ! "$?" = 0; then
				echo "sedreplace: problem moving \"$FILE\" to \"$FILE.b4sr\"" >&2
				echo "Aborting!"
				exit 1
			fi
		fi
		mv "$TMPFILE" "$FILE" ||
			echo "sedreplace: problem moving \"$TMPFILE\" over \"$FILE\"" >&2
	fi
done
