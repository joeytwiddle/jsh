CACHEFILE="$HOME/.msgid_cache.formail"

if test "$1" = ""; then
	echo "removeduplicatemails [ -d | -f ] <mailbox_file>..."
	echo "  Recommended usage:"
	echo "    removeduplicatemails -d <folders_which_together_should_contain_no_duplicates>..."
	echo "  Note: this will delete duplicate mails even if you received them differently,"
	echo "  because it looks at message ID, as opposed to all the headers."
	echo "  Therefore in each case below only one email will remain in your mailboxes:"
	echo "    a mail you sent to a list, received from the list, and CCed to yourself"
	echo "    a mail sent to two of your lists (one will get removed!)"
	echo "  (Warning: message IDs (cksums) are not guaranteed to be unique, so if"
	echo "   you are really unlucky it is possible that this will delete non-duplicates!)"
	exit 0
fi

if test "$1" = "-f"; then
	shift
elif test "$1" = "-d"; then
	shift
	rm -f "$CACHEFILE"
else
	if test -f "$CACHEFILE"; then
		echo "Warning, message ID cache file $CACHEFILE already contains a list of previously seen messages."
		echo "Use -d to delete the cache, or -f to force removal of these messages."
		exit 1
	fi
fi

for X
do
	if test ! -f "$X"; then
		echo "removeduplicatemails: \"$X\" does not exist!"
	else

		OLDSZ=`ls -l "$X" | takecols 5`

		formail -D 10000000 "$CACHEFILE" -s < "$X" > "$X-new" &&
		mv "$X-new" "$X" ||
		echo "removeduplicatemails: Error processing $X"

		SZ=`ls -l "$X" | takecols 5`
		test "$OLDSZ" = "0" && COMPRESSION="0" ||
		COMPRESSION=` expr "(" "$OLDSZ" - "$SZ" ")" "*" "100" "/" "$OLDSZ" `
		echo "Shrunk by $COMPRESSION%: $X (from $OLDSZ to $SZ)"
		# echo "You should delete" mbox.* 2> /dev/null

	fi
done
