# CRASHFILE="$HOME/.galeon/session_crashed.xml"
# if test -f "$CRASHFILE"; then
	# echo "Galeon crash file present."
	# CRASHLINES=`grep "url=" "$CRASHFILE" | countlines`
	# if test "$CRASHLINES" -lt 2; then
		# echo "Deleting because only 1 url."
		# del "$CRASHFILE"
	# fi
# fi
`jwhich galeon` "$@"
