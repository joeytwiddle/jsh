#!/bin/sh
# jsh-depends: jdeltmp jgettmp
# this-script-does-not-depend-on-jsh: filename
if [ "$*" = "" ] || [ "$1" = --help ]
then
	echo 'sedreplace [ <options> ] "search_string" "replace_string" [ <filename>... ]'
	echo "  where <options> ="
	echo "    -nobackup : do not create backup in <filename>.b4sr"
	# currently doesn't actually show # of changes
	echo "    -changes : shows files for which no changes were made."
	exit 1
fi

if test "$3" = ""; then

	sed "s$1$2g"

else

	DOBACKUP=true
	if test "$1" = "-nobackup"; then
		shift
		DOBACKUP=
	fi
	SHOWCHANGES=
	if test "$1" = "-changes"; then
		shift
		SHOWCHANGES=true
	fi
	FROM="$1"
	TO="$2"
	shift
	shift

	TMPFILE=`jgettmp sedreplace$$`

	for FILE do
		if test ! -w "$FILE"; then
			echo "sedreplace: $FILE not writeable" >&2
			continue
		fi
		if test ! -f "$FILE"
		then
			echo "sedreplace: $FILE is not a file" >&2
			continue
		fi
		cat "$FILE" | sed "s$FROM$TOg" > "$TMPFILE"
		## TODO: what about symlinks?  Is it better to cat over?
		chmod --reference="$FILE" "$TMPFILE"
		# Shouldn't I be checking for SHOWCHANGES here?
		if cmp "$FILE" "$TMPFILE" >&2; then
			test $SHOWCHANGES && echo "sedreplace: no changes made to $FILE" >&2
			jdeltmp "$TMPFILE"
		else
			## TODO: sometimes we move it sometimes we don't!
			if [ "$DOBACKUP" ]
			then
				cp "$FILE" "$FILE.b4sr"
				if [ ! "$?" = 0 ]
				then
					echo "sedreplace: problem moving \"$FILE\" to \"$FILE.b4sr\"" >&2
					echo "Aborting!"
					exit 1
				fi
			fi
			## Maybe this'll do better at preserving permissions (links?!)?
			# mv "$TMPFILE" "$FILE" ||
			cat "$TMPFILE" > "$FILE" &&
				jdeltmp "$TMPFILE" ||
				echo "sedreplace: problem moving \"$TMPFILE\" over \"$FILE\"" >&2
		fi
	done

fi
