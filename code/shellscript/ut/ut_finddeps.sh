ALL_UT_FILES="/stuff/software/games/unreal/server/ /home/oddjob2/ut_server/ut-server/ /mnt/big/ut_win_pure"

REGEXP_OF_PACKAGE_NAMES_TO_IGNORE="\("`
	(
		find /mnt/big/ut_win_pure -name "*.u*" |
		afterlast / | beforelast "\."
		echo "Color"
		echo "MyLevel"
	) |
	toregexp |
	sed 's+.$+\0\\\\|+' | tr -d '\n'
`"\)"

# jshinfo ">$REGEXP_OF_PACKAGE_NAMES_TO_IGNORE<"

FILE="$1"

[ "$DEPDBDIR" ] || DEPDBDIR="/stuff/software/games/unreal/dependencydb"
mkdir -p "$DEPDBDIR"

# ALL_PACKAGES_LIST=/tmp/ut_files.names.list
ALL_PACKAGES_LIST="$DEPDBDIR"/all_packages.list

if [ "$1" = -builddb ]
then
	find $ALL_UT_FILES -name "*.unr" |
	catwithprogress |
	while read MAPFILE
	do
		verbosely ut_finddeps "$MAPFILE"
	done
	exit
fi

put_line_in_collection () {
	LINE="$1"
	COLLECTION_FILE="$2"
	if [ ! -f "$COLLECTION_FILE" ]
	then touch "$COLLECTION_FILE"
	fi
	(
		cat "$COLLECTION_FILE" # | grep -v "^`toregexp "$LINE"`$" >/dev/null
		echo "$LINE"
	) |
	removeduplicatelines |
	dog "$COLLECTION_FILE"
}

# jshinfo "Updating ut files list"
# memo find $ALL_UT_FILES -type f -name '*.u*' | afterlast / | beforelast "\." | catwithprogress > "$ALL_PACKAGES_LIST"
# memo eval "find $ALL_UT_FILES -type f -name '*.u*' | afterlast / | beforelast '\.'" | catwithprogress > "$ALL_PACKAGES_LIST"
# memo eval "find $ALL_UT_FILES -type f -name '*.u*' | afterlast / | beforelast '\.'" > "$ALL_PACKAGES_LIST"
# memo -t "1 hour" verbosely eval "find $ALL_UT_FILES -type f -name '*.u*' | afterlast / | beforelast '\.' | grep -v '^\\(ctf\\|dm\\|jb\\|dom\\|as\\)-'" > "$ALL_PACKAGES_LIST"
# memo -t "1 hour" verbosely eval " find $ALL_UT_FILES -type f -name '*.u*' | afterlast / | grep -v '\\.unr$' | beforelast '\.' " > "$ALL_PACKAGES_LIST"
memo -t "1 hour" verbosely eval " find $ALL_UT_FILES -type f -name '*.u*' | afterlast / | grep -v '\\.unr$' | beforelast '\.' > '$ALL_PACKAGES_LIST'"
## TODO: we should also touch the .neededby (the .dependson?) so that we can see which packages are not needed by anything.  ATM they won't appear in the metadata dir.
## Tho we could find them with: cat "$ALL_PACKAGES_LIST" | while read PACKAGE; do [ -f "$DEPDBDIR"/"$PACKAGE".neededby ] || echo "! $PACKAGE"; done

# ALL_PACKAGES_REGEXP='^\('"`cat "$ALL_PACKAGES_LIST" | toregexp | trimempty | sed 's+$+\\\\|+' | tr -d '\n' | sed 's+..$++'`"'\)$'
# jshinfo "Testing ALL_PACKAGES_REGEXP: $ALL_PACKAGES_REGEXP"
# jshinfo "Testing ALL_PACKAGES_REGEXP:"
# echo "test" | grep "$ALL_PACKAGES_REGEXP"
# jshinfo "Result: $?"

FILENAME=`filename "$FILE"`

jshinfo "Scanning $FILE"
cat "$FILE" |
# strings |
strings -n 1 |
sed 's+^[	]*++' |

# pipeboth |

## We want to trim weird chars; they don't search well, and there are many of them!  We try to only get the first part of the file, which is relevant.
# toline -x "^[^0-9A-Za-z()\"'_\[\]]" | ## sometimes premature :(
# toline -x "^\\\$\$" |
# head -n 10000 | ## let too much through
while read LINE
do
	LEN=`strlen "$LINE"`
	if [ "$LEN" -lt 3 ]
	then
		CONCURRENT_SHORT_LINES=$((CONCURRENT_SHORT_LINES+1))
		if [ "$CONCURRENT_SHORT_LINES" -gt 10 ]
		then while read L; do :; done ## break out!
		fi
	else
		CONCURRENT_SHORT_LINES=0
	fi
	echo "$LINE"
done |

tolowercase |
# catwithprogress |
# while read STRING
toregexp |
while read REGEXP
do
	# jshinfo "Considering $REGEXP"
	# grep -i "^$STRING$" "$ALL_PACKAGES_LIST" >/dev/null &&
	# echo "$STRING" # ||
	# echo "$FILE does not need $STRING"
	# REGEXP=`toregexp "$STRING"`
	# grep -i "^$REGEXP$" "$ALL_PACKAGES_LIST"
	[ "$DEBUG" ] && debug "regexp=$REGEXP"
	if grep -i "^$REGEXP$" "$ALL_PACKAGES_LIST"
	then
		DEPENDENCY=`grep -i "^$REGEXP$" "$ALL_PACKAGES_LIST" | head -n 1`
		put_line_in_collection "$DEPENDENCY" "$DEPDBDIR"/"$FILENAME".depends_on
		put_line_in_collection "$FILENAME" "$DEPDBDIR"/"$DEPENDENCY".is_needed_by
		CONCURRENT_ERRORS=0
	else
		ERR="$?"
		if [ ! "$ERR" = 1 ]
		then
			jshinfo "ut_finddeps error $ERR with regexp \"$REGEXP\""
			CONCURRENT_ERRORS=$((CONCURRENT_ERRORS+1))
			if [ "$CONCURRENT_ERRORS" -gt 10 ]
			then
				jshwarn "so many concurrent errors ($CONCURRENT_ERRORS), skipping rest of scan"
				while read X; do :; done
			fi
		fi
	fi
# done
done |
grep -v "^$REGEXP_OF_PACKAGE_NAMES_TO_IGNORE\$" |
removeduplicatelines

# grep "$ALL_PACKAGES_REGEXP" |
# while read DEPENDENCY
# do
	# put_line_in_collection "$DEPENDENCY" "$DEPDBDIR"/"$FILENAME".depends_on
	# put_line_in_collection "$FILENAME" "$DEPDBDIR"/"$DEPENDENCY".is_needed_by
	# echo "$DEPENDENCY"
# done

# | countlines
# done |
# pipebackto /dev/stdout
