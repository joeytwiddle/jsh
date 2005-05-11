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

jdoc showjshtooldoc "$SCRIPT" |
head -50 |
striptermchars | ## Highlighted lines can throw off fromline (awk)
# pipeboth |
grep -v "^# " | ## intended to avoid non-English comments, as per my commenting policy.  Actually mainly needed in case a "# jsh-depends: ..." has been added before the one-line description comment.
fromline -x "^:*$" |
fromline -x "^:*$" |
# pipeboth |
trimempty |
sed 's+^[# 	*]*\<jsh-help\>[: 	]*++' | ## TODO: actually we should detect jsh-help and use it if present
cat |

(

	read LINE

	## If the first line is syntax description,
	if echo "$LINE" | grep "^[ 	]*$SCRIPTNAME " > /dev/null ## or | tr '\n' ' ' to keep the syntax line
	then ## then skip to the second.
		read LINE
		[ "$DEBUG" ] && debug "LINE=$LINE"
	fi

	## Ignore all the other lines.  TODO: I would have thought this would block if no lines are left/EOF (it would wait for a new input stream).  Maybe I'm wrong.
	cat > /dev/null

	echo "$LINE"

)
