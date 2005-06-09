ALL_UT_FILES="/stuff/software/games/unreal/server/ /home/oddjob2/ut_server/ut-server/ /mnt/big/ut"

FILE="$1"

TMPFILE=/tmp/ut_files.names.list

jshinfo "Updating ut files list"
# memo find $ALL_UT_FILES -type f -name '*.u*' | afterlast / | beforelast "\." | catwithprogress > "$TMPFILE"
# memo eval "find $ALL_UT_FILES -type f -name '*.u*' | afterlast / | beforelast '\.'" | catwithprogress > "$TMPFILE"
# memo eval "find $ALL_UT_FILES -type f -name '*.u*' | afterlast / | beforelast '\.'" > "$TMPFILE"
memo eval "find $ALL_UT_FILES -type f -name '*.u*' | afterlast / | beforelast '\.' | grep -v '^\\(ctf\\|dm\\|jb\\|dom\\|as\\)-'" > "$TMPFILE"

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
	# grep -i "^$STRING$" "$TMPFILE" >/dev/null &&
	# echo "$STRING" # ||
	# echo "$FILE does not need $STRING"
	# REGEXP=`toregexp "$STRING"`
	grep -i "^$REGEXP$" "$TMPFILE"
done
# done |
# pipebackto /dev/stdout
