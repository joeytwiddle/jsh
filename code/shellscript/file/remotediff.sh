if test "$1" = "" -o "$2" = ""; then
	echo "remotediff <local-dir> <user>@<host>:<remote-dir> [ <find_options>... ]"
	exit 1
fi

LOCAL="$1"
REMOTESTRING="$2"
shift
shift

RUSER=`echo "$REMOTESTRING" | sed "s/@.*//"`
RHOST=`echo "$REMOTESTRING" | sed "s/.*@//" | sed "s/:.*//"`
RDIR=`echo "$REMOTESTRING" | sed "s/.*://"`

TMPONE=`jgettmp local.cksum`
TMPTWO=`jgettmp remote.cksum`
TMPTHREE=`jgettmp difference.txt`

FINDOPTS="-type f $@"

CKSUMCOM='
	while read X; do
		date "+%Y/%m/%d-%H:%M:%S" -r "$X" | tr -d "\n"
		printf " "
		cksum "$X"
	done |
	tr "\t" " " |
	grep -v "/CVS/"
'
		# ls -l "$X" |
		# sed "s/[^ ]*[ ]*[^ ]*[ ]*[^ ]*[ ]*[^ ]*[ ]*//;s/ .*//"

# REMOTECOM='find "'"$RDIR"'" '"$FINDOPTS"' | '"$CKSUMCOM"
REMOTECOM='cd "'"$RDIR"'" && find . '"$FINDOPTS"' | '"$CKSUMCOM"



# Try to use (g)vimdiff or jfc if available
if test ! "$DIFFCOM"; then
	## Note jfc not suitable because currently one-way only
	DIFFCOMS="gvimdiff vimdiff jfc jdiff diff"
	for X in $DIFFCOMS; do
		if test "$DIFFCOM" = "" && which "$X" > /dev/null 2>&1; then
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

DIFFCOM="myspecialdiff"

myspecialdiff () {
	EDITFILE=`jgettmp remotediff.edit`
	jfcsh "$1" "$2" > "$1.only"
	jfcsh "$2" "$1" > "$2.only"
	(
		cat "$1.only" |
		while read X; do grep "$X$" "$1.longer"; done |
		sed "s/^/local /"
		cat "$2.only" |
		while read X; do grep "$X$" "$2.longer"; done |
		sed "s/^/remote /"
	) |
	sort -k 2 | sort -s -k 5 |
	column -t -s '   ' > "$EDITFILE"

	vim "$EDITFILE"

	TOGO=`
		cat "$EDITFILE" | grep "^local " |
		while read LOCATION DATETIME CKSUM LEN FILENAME; do
			printf "\"$LOCAL/$FILENAME\" "
		done
	`
	TOCOME=`
		cat "$EDITFILE" | grep "^remote " |
		while read LOCATION DATETIME CKSUM LEN FILENAME; do
			printf "\"$RUSER@$RHOST:$RDIR/$FILENAME\" "
		done
	`
	echo
	test ! "$TOGO" = "" &&
		echo "scp -B $TOGO$RUSER@$RHOST:$RDIR/"
	test ! "$TOCOME" = "" &&
		echo "scp -B $TOCOME$LOCAL/"
}

echo "Getting cksums for remote $RHOST:$RDIR"
ssh -l "$RUSER" "$RHOST" "$REMOTECOM" > "$TMPTWO.longer" && echo "Got remote" &

echo "Getting cksums for local $LOCAL"
cd "$LOCAL" && find . $FINDOPTS | sh -c "$CKSUMCOM" > "$TMPONE.longer" && echo "Got local" &

wait



cat "$TMPONE.longer" | cut -d " " -f 2,3,4 > "$TMPONE"
cat "$TMPTWO.longer" | cut -d " " -f 2,3,4 > "$TMPTWO"

# Diff works badly if not sorted
preparefordiff () {
	sort -k 3 "$TMPONE" > "$TMPONE.sorted"
	sort -k 3 "$TMPTWO" > "$TMPTWO.sorted"
	TMPONE="$TMPONE.sorted"
	TMPTWO="$TMPTWO.sorted";
}

if test "$DIFFCOM" = "diff" -o "$DIFFCOM" = "vimdiff" -o "$DIFFCOM" = "gvimdiff" -o "$DIFFCOM" = "jdiff"; then
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
