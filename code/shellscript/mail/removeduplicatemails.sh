CACHEFILE="$HOME/.msgid_cache.formail"

reusemsg() {
cat << !
  Note: Re-use is dangerous, because if yous can the same folder, it will
    remove all the msgs as already seen!  Similary, never list an mbox twice!
!
}

if test "$1" = ""; then
cat << !
removeduplicatemails ( -d | -f ) <mailbox_files>...
  where -d deletes the old msgID cache, -f forces re-use of the old cache.
`reusemsg`
  Recommended usage:
    removeduplicatemails -d <folders_to_scan>...
  Note: This will delete any duplicate copies of an email encountered if even
    if you received them differently, because it looks at message ID (hash of
    contents), as opposed to all the headers.
    Therefore in each case below only one email will remain in your mailboxes:
       a mail you sent to a list, received from the list, and CCed to yourself
       a mail sent to two of your lists (one will get removed!)
!
# (Warning: message IDs (cksums) are not guaranteed to be unique, so if
# you are really unlucky it is possible that this will delete non-duplicates!)
exit 0
fi

if test "$1" = "-d"; then
	shift
	rm -f "$CACHEFILE"
elif test "$1" = "-f"; then
	shift
else
if test -f "$CACHEFILE"; then
cat << !
Warning, message ID cache file $CACHEFILE already contains a list of previously seen messages.
Use -d to delete the cache, or -f to force removal of these messages.
!
reusemsg
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
		mv "$X-new" "$X"
		if test ! "$?" = "0"; then
			echo "removeduplicatemails: Error processing $X"
			exit 1
		fi

		SZ=`ls -l "$X" | takecols 5`
		test "$OLDSZ" = "0" && COMPRESSION="0" ||
		COMPRESSION=` expr "(" "$OLDSZ" - "$SZ" ")" "*" "100" "/" "$OLDSZ" `
		echo "Shrunk by $COMPRESSION%: $X (from $OLDSZ to $SZ)"
		# echo "You should delete" mbox.* 2> /dev/null

	fi
done
