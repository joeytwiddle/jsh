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
		mv "$X" "$X-old"
		formail -D 10000000 "$CACHEFILE" -s < "$X-old" > "$X"
		OLDSZ=`ls -l "$X-old" | takecols 5`
		SZ=`ls -l "$X" | takecols 5`
		test ! "$OLDSZ" = "0" &&
		COMPRESSION=` expr "(" "$OLDSZ" - "$SZ" ")" "*" "100" "/" "$OLDSZ" ` ||
		COMPRESSION="0"
		echo "Shrunk by $COMPRESSION%: $X (from $OLDSZ to $SZ)"
		if test ! "$COMPRESSION" = 0 && ! cmp "$X" "$X-old" > /dev/null 2>&1 ; then
			REFRESH="$X".*
			if test ! "$REFRESH" = "$X.*"; then
				del "$X.ibex" "$X.ev-summary" > /dev/null 2>&1
				REFRESH="$X".*
				if test ! "$REFRESH" = "$X"; then
					echo "You probably need to delete index (generated) files: " "$X".*
				fi
			fi
		elif test "$COMPRESSION" = 0 && cmp "$X" "$X-old" > /dev/null 2>&1 ; then
			rm -f "$X-old"
		fi
	fi
done
