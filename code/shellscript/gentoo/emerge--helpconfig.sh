## NOTE: not yet tested on /multiple/ updates per conf-file

CONFIGLIST=/tmp/config-matches.list

## No this is no good cos we need to compare against the checksum of the conffile in the /old/ package!
if [ "$1" = "-new" ]
then

	find /etc -iname '._cfg????_*' |

	while read NEWCONFIG
	do
		CONFIG=`echo "$NEWCONFIG" | sed 's+/\._cfg...._+/+'`
		# PACKAGES=`qpkg -f "$CONFIG" | striptermchars | takecols 1`
		grep "^[^ ]* $CONFIG " /var/db/pkg/*/*/CONTENTS |
		sed 's+/var/db/pkg/\([^:]*\)/CONTENTS:\([^ ]*\) \([^ ]*\) \([^ ]*\) \(.*\)+\1 \2 \3 \4 \5+' |
		while read PACKAGE FILETYPE FILE MD5SUM LENGTH
		do
			[ "$FILE" = "$CONFIG" ] || jsherror "Expected $FILE = $CONFIG"
			EXPECTEDSUM="$MD5SUM  $FILE"
			GOTSUM=`md5sum "$FILE"`
			if [ "$EXPECTEDSUM" = "$GOTSUM" ]
			then
				echo "$FILE `cursegreen`matches`cursenorm` $PACKAGE"
				echo "Recommend: mv -f \"$NEWCONFIG\" \"$CONFIG\""
			else
				echo "$FILE `cursered`mismatches`cursenorm` $PACKAGE"
				echo "  expected: $EXPECTEDSUM"
				echo "  got     : $GOTSUM"
				echo "If no others match, you could: vimdiff \"$NEWCONFIG\" \"$CONFIG\""
			fi
		done	

	done

	exit

fi	

## Old method:
## Hmm I think this works on the principle that the conffile matched the one in a package /when you did the scan/.

if [ "$1" = scan ]
then

	ls -l "$CONFIGLIST"

	cd /var/db/pkg

	'ls' -d */* |

	while read GROUPNAMEVER
	do

		cat $GROUPNAMEVER/CONTENTS |
		grep -v "^dir " |

		grep "[^ ]* /etc/" |

		while read TYPE FILE MD5SUM SIZE
		do
			[ -f "$FILE" ] || continue
			EXPECTEDSUM="$MD5SUM  $FILE"
			GOTSUM=`md5sum "$FILE"`
			if [ "$EXPECTEDSUM" = "$GOTSUM" ]
			then
				echo "$GOTSUM `cursegreen`matches`cursenorm` $GROUPNAMEVER"
			else
				echo "$FILE `cursered`mismatches`cursenorm` $GROUPNAMEVER"
			fi
		done

	done |

	pipeboth |

	striptermchars >> "$CONFIGLIST"

	echo "  added to $CONFIGLIST"
	ls -l "$CONFIGLIST"
	echo "Removing duplicates..."
	cat "$CONFIGLIST" | removeduplicatelines | dog "$CONFIGLIST"
	ls -l "$CONFIGLIST"

elif [ "$1" = check ]
then

	find /etc -iname '._cfg????_*' |
	while read NEWCONFIG
	do
		CONFIG=`echo "$NEWCONFIG" | sed 's+/\._cfg...._+/+'`
		GOTSUM=`md5sum "$CONFIG"`
		if grep "^$GOTSUM matches" "$CONFIGLIST"
		then echo "Therefore it should be fine to: `cursecyan`mv '$NEWCONFIG' '$CONFIG'`cursenorm`"
		elif grep "^$CONFIG mismatches" "$CONFIGLIST"
		then echo "So you might want to: `cursecyan`vimdiff '$NEWCONFIG' '$CONFIG'`cursenorm`"
		else echo "$CONFIG was not recognised."
		fi
		echo
	done

	echo "No more config files need merging."

elif [ "$1" = fullcheck ]
then

	find /etc -type f |
	while read CONFIG
	do
		GOTSUM=`md5sum "$CONFIG"`
		grep "^$GOTSUM matches" "$CONFIGLIST" ||
		grep "^$CONFIG mismatches" "$CONFIGLIST" ||
		echo "$CONFIG was not recognised."
	done

else

	echo "Don't understand: \"$1\"  Try \"scan\" then \"check\""
	exit 1

fi
