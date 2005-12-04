ALL_UT_FILES="/stuff/software/games/unreal/server/ /home/oddjob2/ut_server/ut-server/ /mnt/big/ut_win"

FILE="$1"

DEPDBDIR="/stuff/software/games/unreal/server/dependencydb"
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

jshinfo "Updating ut files list"
# memo find $ALL_UT_FILES -type f -name '*.u*' | afterlast / | beforelast "\." | catwithprogress > "$ALL_PACKAGES_LIST"
# memo eval "find $ALL_UT_FILES -type f -name '*.u*' | afterlast / | beforelast '\.'" | catwithprogress > "$ALL_PACKAGES_LIST"
# memo eval "find $ALL_UT_FILES -type f -name '*.u*' | afterlast / | beforelast '\.'" > "$ALL_PACKAGES_LIST"
memo -t "1 hour" eval "find $ALL_UT_FILES -type f -name '*.u*' | afterlast / | beforelast '\.' | grep -v '^\\(ctf\\|dm\\|jb\\|dom\\|as\\)-'" > "$ALL_PACKAGES_LIST"
## TODO: we should also touch the .neededby (the .dependson?) so that we can see which packages are not needed by anything.  ATM they won't appear in the metadata dir.
## Tho we could find them with: cat "$ALL_PACKAGES_LIST" | while read PACKAGE; do [ -f "$DEPDBDIR"/"$PACKAGE".neededby ] || echo "! $PACKAGE"; done

FILENAME=`filename "$FILE"`

jshinfo "Scanning $FILE"
cat "$FILE" |
strings |
sed 's+^[	]*++' |
toline -x "^[^0-9A-Za-z()\"'_\[\]]" |
tolowercase |
# catwithprogress |
# while read STRING
toregexp |
while read REGEXP
do
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
	fi
# done
done | countlines
# done |
# pipebackto /dev/stdout
