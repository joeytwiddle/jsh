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

	cat "$EDITFILE" | grep "^local " |
	while read LOCATION DATETIME CKSUM LEN FILENAME; do
		echo "$LEN $RDIR/$FILENAME"
		cat "$LOCAL/$FILENAME"
	done |
	ssh -C $RUSER@$RHOST '
		while read LEN FILENAME; do
			printf "Writing $FILENAME..." >&2
			dd bs=1 count=$LEN > "$FILENAME"
			echo "done." >&2
		done
	'

	cat "$EDITFILE" | grep "^remote " |
	while read LOCATION DATETIME CKSUM LEN FILENAME; do
		echo "$LEN $FILENAME"
	done |
	ssh -C $RUSER@$RHOST '
		while read LEN FILENAME; do
			echo "$LEN $FILENAME"
			cat "'"$RDIR"'/$FILENAME"
		done
	' |
	while read LEN FILENAME; do
		printf "Reading $FILENAME..." >&2
		dd bs=1 count=$LEN > "$LOCAL/$FILENAME"
		echo "done." >&2
	done

	# echo "rsync -vv -P -r --exclude=\"*\" --include-from=tosend.list \"$LOCAL/\" \"$RUSER@$RHOST:$RDIR/\""
	# echo "rsync -vv -P -r --exclude=\"*\" --include-from=tobring.list \"$RUSER@$RHOST:$RDIR/\" \"$LOCAL/\""

}

echo "Getting cksums for local $LOCAL"
cd "$LOCAL" && find . $FINDOPTS | sh -c "$CKSUMCOM" > "$TMPONE.longer" && echo "Got local" &

echo "Getting cksums for remote $RHOST:$RDIR"
ssh -C -l "$RUSER" "$RHOST" "$REMOTECOM" > "$TMPTWO.longer" && echo "Got remote" &

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
