if test "$1" = "" -o "$2" = ""; then
	echo "remotediff <local-dir> <user>@<host>:<remote-dir>"
	exit 1
fi

LOCAL="$1"
REMOTESTRING="$2"

RUSER=`echo "$REMOTESTRING" | sed "s/@.*//"`
RHOST=`echo "$REMOTESTRING" | sed "s/.*@//" | sed "s/:.*//"`
RDIR=`echo "$REMOTESTRING" | sed "s/.*://"`

TMPONE="/tmp/local.cksum"
TMPTWO="/tmp/remote.cksum"
TMPTHREE="/tmp/difference.txt"

FINDOPTS="-type f"

CKSUMCOM='while read X; do cksum "$X"; done | tr "\t" " " | grep -v "/CVS/"'

# REMOTECOM='find "'"$RDIR"'" '"$FINDOPTS"' | '"$CKSUMCOM"
REMOTECOM='cd "'"$RDIR"'"; find . '"$FINDOPTS"' | '"$CKSUMCOM"



# Try to use (g)vimdiff or jfc if available
if test ! "$DIFFCOM"; then
	DIFFCOMS="gvimdiff vimdiff jfc diff"
	for X in $DIFFCOMS; do
		if test "$DIFFCOM" = "" && which "$X" > /dev/null; then
			DIFFCOM="$X"
		fi
	done
	if test "$DIFFCOM" = ""; then
		echo "Could not find any diffing program (tried $DIFFCOMS)."
		echo "Files are in $TMPONE and $TMPTWO."
		exit 1
	fi
fi
# echo "Will use \"$DIFFCOM\" for diffing."



echo "Getting cksums for remote $RHOST:$RDIR"
ssh -l "$RUSER" "$RHOST" "$REMOTECOM" > "$TMPTWO" && echo "Got remote" &

echo "Getting cksums for local $LOCAL"
cd "$LOCAL"; find . $FINDOPTS | sh -c "$CKSUMCOM" > "$TMPONE" && echo "Got local" &

wait



# Diff works badly if not sorted
preparefordiff () {
	sort -k 3 "$TMPONE" > "$TMPONE.sorted"
	sort -k 3 "$TMPTWO" > "$TMPTWO.sorted"
	TMPONE="$TMPONE.sorted"
	TMPTWO="$TMPTWO.sorted";
}

if test "$DIFFCOM" = "diff" -o "$DIFFCOM" = "bimdiff" -o "$DIFFCOM" = "gvimdiff"; then
	preparefordiff
fi

# Removing cksum columns for the different diff-ers:
# ( jfc "$TMPONE" "$TMPTWO" | ( takecols 5 || cat ) ) || ( diff "$TMPONE" "$TMPTWO" | ( takecols 1 4 || cat ) )



# echo "Comparing $LOCAL to $RHOST:$RDIR using $DIFFCOM ..."
echo "Comparing local to remote using \"$DIFFCOM\" ..."

"$DIFFCOM" "$TMPONE" "$TMPTWO" | tee "$TMPTHREE"

# # Commented not working
# 
# # This summary is a bit haphazard because jfc and diff act differently,
# # and gvimdiff and vimdiff don't give any output!
# 
# # Works for diff:
# # RESULT=`cat "$TMPTHREE"`
# # if test "$RESULT"; then
# # Works for jfc, don't know why not for diff (tried #!/bin/bash):
# if test ! "$?" = "0"; then
	# echo "There were differences. :-("
	# echo "  Although if you are using vimdiff (as opposed to a com-line tool) this might not be true."
	# exit 1
# else
	# NUMS1=`countlines "$TMPONE"`
	# NUMS2=`countlines "$TMPTWO"`
	# if test "$NUMS1" = "$NUMS2"; then
		# echo "All $NUMS1 lines appear to be the same =)"
		# echo "  Although if you are using vimdiff (as opposed to a com-line tool) this might not be true."
		# exit 0
	# else
		# echo "Error: \"$DIFFCOM\" found them the same but linecount $NUMS1 != $NUMS2."
		# echo "  Although if you are using vimdiff (as opposed to a com-line tool) this is probably not an error."
		# exit 1
	# fi
# fi
# 
# exit 123
