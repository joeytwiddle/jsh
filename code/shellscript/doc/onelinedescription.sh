## Extract a one-line description of a script from its help or its content, making use of documentation policy.
## It assumes the policy that, ignoring empty lines, either:
##   - the first line contains a one-line description.
##   - or, the first line contains a syntax description starting with the name of the script,
##     and the second line contains the description.

SCRIPT="$1"
if [ ! -f "$SCRIPT" ]
then SCRIPT="$JPATH/tools/$SCRIPT"
fi

export SCRIPTNAME=`basename "$SCRIPT" sh`
[ "$DEBUG" ] && debug "SCRIPTNAME=$SCRIPTNAME"

seek_help () {
	if jdoc -hasdoc "$SCRIPT"
	then
		"$SCRIPT" --help |
		grep -v "^[ 	]*$SCRIPTNAME "
	fi
}

seek_jshhelp () {
	JSHHELPEXPR="^[# 	*]*\<jsh-help\>[: 	]*"
	cat "$SCRIPT" |
	grep "$JSHHELPEXPR" |
	sed "s+$JSHHELPEXPR++g"
}

seek_comment () {
	COMMENTEXPR="^##[ 	]*"
	cat "$SCRIPT" |
	grep "$COMMENTEXPR" |
	# sed "s+$COMMENTEXPR++g" |
	# grep -v "^[A-Z]*:" | ## Avoids lines starting e.g. "TODO: "
	# sed 's+^+(#) +g' | ## This added just for debug (so we know which ones were comments)
	# sed 's+^+# +g' | ## This added just for debug (so we know which ones were comments)
	cat
}

give_up () {
	echo '???'
}

for METHOD in seek_help seek_jshhelp seek_comment give_up
do

	[ "$DEBUG" ] && debug "Trying method $METHOD"

	LINE=`
		"$METHOD" "$SCRIPT" |
		trimempty |
		head -n 1
	`
	if [ "$LINE" ]
	then
		[ "$DEBUG" ] && debug "Method $METHOD worked!"
		break
	fi

done

echo "$LINE"

# jdoc showjshtooldoc "$SCRIPT" |
# head -50 |
# striptermchars | ## Highlighted lines can throw off fromline (awk)
# # pipeboth |
# grep -v "^# " | ## intended to avoid non-English comments, as per my commenting policy.  Actually mainly needed in case a "# jsh-depends: ..." has been added before the one-line description comment.
# fromline -x "^:*$" |
# fromline -x "^:*$" |
# # pipeboth |
# sed 's+++' | ## TODO: actually we should detect jsh-help and use it if present
# cat |
