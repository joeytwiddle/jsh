# jsh-depends: qkcksum error
for FILE
do
	mp3gain -u "$FILE"
	mp3gain -s d "$FILE"
	CHECKFILE="$FILE".qkcksum.b4mp3gain
	if [ "$CHECKFILE" ]
	then
		CHECK=`qkcksum "$FILE" | takecols 1 2`
		SHOULDBE=`cat "$CHECKFILE" 2>/dev/null | takecols 1 2`
		if [ "$CHECK" = "$SHOULDBE" ] || [ "$SHOULDBE" = "" ]
		then
			# jshinfo "Restored ok :)"
			[ -f "$CHECKFILE" ] && del "$CHECKFILE"
		else
			error "Failed match:"
			error "CHECK    = $CHECK"
			error "SHOULDBE = $SHOULDBE"
			[ -f "$CHECKFILE" ] && del "$CHECKFILE" ## who cares if it failed - we tried the best we could so now this file is redundant.
		fi
	else
		jshwarn "I hope that worked, because I couldn't find a .qkcksum.b4mp3gain file to check against."
	fi
done
