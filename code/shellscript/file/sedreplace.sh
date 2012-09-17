#!/bin/sh
# jsh-depends: jdeltmp jgettmp
# jsh-depends-ignore: filename

if [ "$*" = "" ] || [ "$1" = --help ]
then
	echo
	echo 'sedreplace [ <options> ] "search_string" "replace_string" [ <filename>... ]'
	echo
	echo "Options (not yet finalised):"
	echo
	echo "  -verify    asks user whether to accept replacement, per-file."
	echo
	echo "  -nobackup  do not create backup in <filename>.b4sr"
	echo
	# currently doesn't actually show # of changes
	echo "  -changes   shows files for which changes were made."
	echo
	echo "  -nonochanges   hides files for which no changes were made."
	echo
	exit 1
fi

## DONE: We could use grep -l "$pattern" to select the relevant file only,
## assuming grep and sed use exactly the same regexp syntax.  This would only
## be useful if the user specified a lot of files.  In which case we might want
## to provide a . -r option for them.
## Here is an external implementation for the moment:
##   grep -l "$pattern" **/* | withalldo sedreplace "$pattern" "$replacement"

## TODO: Expose option to preserveDate, off by default.

## CONSIDER: Better handling of b4sr files?  It might be nice to provide
## "undolastsedreplace" but that would mean keeping only the last, or
## maintaining a fiddly undo list (users would not undo steps per sedreplace
## call, not per file)!

USEGREPFORSPEED=true
SHOWCHANGES=
SHOWNOCHANGES=1
DOBACKUP=true

while true
do
	if [ "$1" = "-nobackup" ]
	then
		DOBACKUP=
		shift
	elif [ "$1" = "-changes" ]
	then
		SHOWCHANGES=1
		shift
	elif [ "$1" = "-nonochanges" ]
	then
		SHOWNOCHANGES=
		shift
	elif [ "$1" = "-verify" ]
	then
		VERIFY=true
		shift
	else
		break
	fi
done
FROM="$1"
TO="$2"
shift
shift

if test "$3" = ""; then

	isatty && echo "[sedreplace] Reading from stdin" >&2
	sed "s$1$2g"

else

	TMPFILE=`jgettmp sedreplace$$`

	for FILE
	do

		if [ ! -w "$FILE" ]
		then
			echo "sedreplace: $FILE not writeable" >&2
			continue
		fi
		if [ ! -f "$FILE" ]
		then
			# echo "sedreplace: $FILE is not a file" >&2
			continue
		fi

		## Optimization - check with grep first; faster than checking after sed.
		## This makes it rather unlikely that SHOWNOCHANGES will be triggered in later checks.
		if [ -n "$USEGREPFORSPEED" ] && ! grep -q "$FROM" "$FILE"
		then
			[ -n "$SHOWNOCHANGES" ] && echo "No changes needed to $FILE - skipping." >&2
			continue
		fi

		## Never do replacements on b4sr files, silently.  I find this desirable.
		if echo "$FILE" | grep -q "\.b4sr$"
		then
			# echo "Skipping $FILE" >&2
			continue
		fi

		# preserveDate="`date -r "$FILE"`"
		cat "$FILE" | sed "s$FROM$TOg" > "$TMPFILE"
		## TODO: what about symlinks?  Is it better to cat over?
		chmod --reference="$FILE" "$TMPFILE"

		if cmp "$FILE" "$TMPFILE" >/dev/null 2>&1
		then

			[ -n "$SHOWNOCHANGES" ] && echo "sedreplace: No changes made to $FILE" >&2
			[ -n "$USEGREPFORSPEED" ] && echo "sedreplace: No changes made to $FILE is rather unexpected since grep matched the regexp!" >&2

			jdeltmp "$TMPFILE"

		else

			if [ -n "$SHOWCHANGES" ] || [ -n "$VERIFY" ]
			then
				echo "$CURSEYELLOW""Changes to $FILE:$CURSENORM"
				diff "$FILE" "$TMPFILE" | diffhighlight -nm
				[ -n "$SHOWCHANGES" ] && echo
			fi

			if [ -n "$VERIFY" ]
			then
				echo -n "Perform these changes (Y/n)? "
				read k
				if [ "$k" = "n" ] || [ "$k" = "N" ]
				then
					echo "Skipping $FILE"
					continue
				else
					echo "Modifying $FILE"
				fi
				echo
			fi

			## TODO: sometimes we move it sometimes we don't!
			if [ -n "$DOBACKUP" ]
			then
				cp "$FILE" "$FILE.b4sr"
				## Apparently cp keeps timestamps and so-on by default (it is scp
				## that doesn't!).  So we don't need:
				# cp -d --preserve=all "$FILE" "$FILE.b4sr"
				if [ ! "$?" = 0 ]
				then
					echo "sedreplace: Problem moving \"$FILE\" to \"$FILE.b4sr\"" >&2
					echo "Aborting!"
					exit 1
				fi
			fi

			## We want to preserve file permissions, but not last-modified
			## timestamp: it is our duty to indicate that the file has been
			## modified (e.g. for build processes like make/ant).

			cat "$TMPFILE" > "$FILE" &&
			jdeltmp "$TMPFILE"
			[ "$?" = 0 ] || echo "sedreplace: Problem moving \"$TMPFILE\" over \"$FILE\"" >&2

		fi

		# touch -d "$preserveDate" "$FILE"

	done

fi
