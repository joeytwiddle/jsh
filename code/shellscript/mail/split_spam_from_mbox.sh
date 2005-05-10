if [ "$#" -lt 3 ]
then
	echo "split_spam_from_mbox <input_mbox> <output_mbox> <spam_output_mbox>"
	## Internally: split_spam_from_mbox -internal <input_mbox> <output_mbox> <spam_output_mbox>
	exit 1
fi

if [ "$1" = -internal ]
then INTERNAL=true; shift
fi

INPUT="$1"
OUTPUT="$2"
SPAM_OUTPUT="$3"

extract_spam_score () {
	## If email already has been scanned and marked, we seem to get the newest score by getting the last score reported, hence the tail.
	## Ah but this doesn't work with spamc!
	# # grep -C 5 "^Content analysis details:" | pipeboth |
	# grep "^Content analysis details:" | pipeboth |
	# tail -n 1 |
	# sed 's+.*(++ ; s+ points.*++'

	## Alternatively we could look for this header which spamassassin adds/overwrites:
	## X-Spam-Status: No, score=-1.9 required=5.0 tests=ALL_TRUSTED,
	## In this case I got duplicated, but the first one was the new one, hence head.
	grep "^X-Spam-Status" |
	pipeboth |
	head -n 1 |
	sed 's+.*\(hits\|score\)=++ ; s+ req.*++'

}

error_exit () {
	error "There was an error!" "$@"
	exit 1
}

if [ "$INTERNAL" ]
then

	TMPFILE=`jgettmp split_spam_from_mbox`
	cat > "$TMPFILE"

	jshinfo "Testing $TMPFILE"

	FILESIZE=`filesize "$TMPFILE"`
	jshinfo "Size: $FILESIZE"

	cat "$TMPFILE" | grep "^From"
	cat "$TMPFILE" | grep "^Subject"

	SCORE_BEFORE=`cat "$TMPFILE" | extract_spam_score`
	if [ "$SCORE_BEFORE" ]
	then jshinfo "Score before: $SCORE_BEFORE"
	fi

	## TODO:
	## I would like to test what happens if I send the output of
	## spamc to the new folder, i.e. send the labelled version not the original.
	## To test, why not also create $OUTPUT.post and $SPAM_OUTPUT.post
	## and vimdiff to see what spamasassin changed.
	## Also, at this point we can see what kind of check we can make to ensure spamc did process the mail successfully.

	SCORE=`
		cat "$TMPFILE" |
		# spamassassin -t |
		spamc |
		extract_spam_score
	`
	jshinfo "New score: $SCORE"

	SAVE_ANYWAY=
	if [ ! "$SCORE" ]
	then
		error "Could not find spamassassin's score!"
		SAVE_ANYWAY=true
	else
		INTSCORE=`echo "$SCORE * 10" | bc | sed 's+\..*++'`
		jshinfo "As integer: $INTSCORE"
	fi

	if [ "$SAVE_ANYWAY" ] || [ "$INTSCORE" -lt 50 ]
	then
		jshinfo "Not spam"
		cat "$TMPFILE" >> "$OUTPUT" || error_exit 1
	else
		jshinfo "Spam!"
		# cat "$TMPFILE" >> "$SPAM_OUTPUT"
		cat "$TMPFILE" | spamc >> "$SPAM_OUTPUT" || error_exit 1
	fi

	jdeltmp "$TMPFILE"

	echo >&2

else

	cat "$INPUT" |
	formail -s split_spam_from_mbox -internal "$INPUT" "$OUTPUT" "$SPAM_OUTPUT"

fi
