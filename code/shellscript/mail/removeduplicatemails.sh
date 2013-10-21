#!/bin/sh
CACHEFILE="$HOME/.msgid_cache.formail"

reusemsg() {
cat << !
  Note: Re-use is dangerous, because if you use the same folder, it will
    remove all the msgs already seen!  Similary, never list an mbox twice
    (eg. accidentally with a symlink)!
!
}

if test "$1" = ""; then
cat << !

removeduplicatemails [ -test ] ( -d | -f ) <mailbox_files>...

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

  The order of <mailbox_files> is important; the first of any duplicates
  encountered will be kept, whilst all latter ones will be removed.

!
# (Warning: message IDs (cksums) are not guaranteed to be unique, so if
# you are really unlucky it is possible that this will delete non-duplicates!)
exit 0
fi

if [ "$1" = -test ]
then TEST=true; shift
fi

if [ "$1" = "-d" ]
then
	shift
	rm -f "$CACHEFILE"
elif [ "$1" = "-f" ]
then
	shift
else
	if [ -f "$CACHEFILE" ]
	then
cat << !
Warning, message ID cache file $CACHEFILE already contains a list of previously seen messages.
Use -d to delete the cache, or -f to force removal of these messages.
!
		reusemsg
		exit 1
	fi
fi

for MBOX
do

	if [ ! -f "$MBOX" ]
	then

		echo "removeduplicatemails: \"$MBOX\" does not exist!"

	else

		OLDSZ=`ls -l "$MBOX" | takecols 5`

		export KNOWN_TOTAL_SIZE=`filesize "$MBOX"`
		export TRICKLE_SHOW_PROGRESS=1
		if
			cat "$MBOX" |
			trickle -at 1000 | ## At 1000k=1Meg per second, this is hardly trickling, only showing progress.  Why not use catwithprogress (passing size thru)?
			formail -D 10000000 "$CACHEFILE" -s > "$MBOX.new"
		then
			if [ ! `filesize "$MBOX"` = `filesize "$MBOX.new"` ]
			then ls -l "$MBOX" "$MBOX.new"
			fi
			if [ "$TEST" ]
			then rm "$MBOX.new"
			else mv "$MBOX.new" "$MBOX"
			fi
		else
			echo "removeduplicatemails: Error processing $MBOX"
			exit 1
		fi

		SZ=`ls -l "$MBOX" | takecols 5`
		if [ "$OLDSZ" = "0" ]
		then COMPRESSION="0"
		else COMPRESSION=` expr "(" "$OLDSZ" - "$SZ" ")" "*" "100" "/" "$OLDSZ" `
		fi
		echo "Shrunk by $COMPRESSION%: $MBOX (from $OLDSZ to $SZ)"
		# echo "You should delete" mbox.* 2> /dev/null

	fi
done
