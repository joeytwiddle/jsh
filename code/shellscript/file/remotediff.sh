if test "$1" = "" -o "$2" = ""; then
	echo "remotediff -diffcom <diff_command> <local-dir> <user>@<host>:<remote-dir> [ <find_options>... ]"
	echo "Supported diff commands: (may be provided in \$DIFFCOM, otherwise chosen from)"
	echo "  gvimdiff"
	echo "  vimdiff"
	echo "  jfc"
	echo "  jdiff"
	echo "  diff"
	echo "  rsyncdiff - Lets you edit diff list then transports files."
	exit 1
fi

### Read parameters

if test "$1" = -diffcom
then
	DIFFCOM="$2"
	shift; shift
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

### Choose an available diff command

if test ! "$DIFFCOM"; then
	## Note jfcsh not suitable because currently one-way only (no longer true - fixit!)
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
	echo "Will use \"$DIFFCOM\" for diffing."
fi
# DIFFCOM="rsyncdiff"

### Set up commands for cksum retrieval

FINDOPTS="-type f $@"

CKSUMCOMEXT=""
if test "$DIFFCOM" = "rsyncdiff"; then
	CKSUMCOMEXT='
		date "+%Y/%m/%d-%H:%M:%S" -r "$X" | tr -d "\n"
		printf " "
	'
fi

CKSUMCOM='
	while read X; do
		'"$CKSUMCOMEXT"'
		cksum "$X"
	done |
	tr "\t" " " |
	grep -v "/CVS/"
'
		# ls -l "$X" |
		# sed "s/[^ ]*[ ]*[^ ]*[ ]*[^ ]*[ ]*[^ ]*[ ]*//;s/ .*//"

# REMOTECOM='find "'"$RDIR"'" '"$FINDOPTS"' | '"$CKSUMCOM"
REMOTECOM='cd "'"$RDIR"'" && find . '"$FINDOPTS"' | '"$CKSUMCOM"



### Get the cksums

echo "Getting cksums for remote $RHOST:$RDIR"
ssh -C -l "$RUSER" "$RHOST" "$REMOTECOM" > "$TMPTWO.longer" && echo "Got remote" &

echo "Getting cksums for local $LOCAL"
cd "$LOCAL" && find . $FINDOPTS | sh -c "$CKSUMCOM" > "$TMPONE.longer" && echo "Got local" &

wait



## Post-process results if required

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



### Finally display the difference

## rsyncdiff - a special diff command which lets you edit the diff and then
## transfers the files for you =)
rsyncdiff () {

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
	## Took out -s "stabilise sort" from second sort for tao
	sort -k 2 | sort -k 5 |
	column -t -s '   ' > "$EDITFILE"

	vim "$EDITFILE"

	## TODO: error handling!
	## eg. Could put exit 1 instead of echo "ERROR"

	## Send local files
	cat "$EDITFILE" | grep "^local " |
	while read LOCATION DATETIME CKSUM LEN FILENAME; do
		echo "$LEN $RDIR/$FILENAME"
		cat "$LOCAL/$FILENAME"
	done |
	ssh -C $RUSER@$RHOST '
		while read LEN FILENAME; do
			printf "Writing $FILENAME..." >&2
			mkdir -p `dirname "$FILENAME"`
			dd bs=1 count=$LEN > "$FILENAME" &&
			echo "done." >&2 ||
			echo "ERROR." >&2
		done
	'

	## Bring remote files and files for diffing
	(
		cat "$EDITFILE" | grep "^remote " |
		while read LOCATION DATETIME CKSUM LEN FILENAME; do
			echo "$LEN $RDIR/$FILENAME"
			echo "$LOCAL/$FILENAME"
		done
		cat "$EDITFILE" | grep "^diff " |
		while read LOCATION DATETIME CKSUM LEN FILENAME; do
			echo "$LEN $RDIR/$FILENAME"
			echo "$LOCAL/$FILENAME.remote"
		done
	) |
	ssh $RUSER@$RHOST '
		while read LEN FILENAME; do
			read GETFILENAME
			echo "$LEN $GETFILENAME"
			cat "$FILENAME"
		done
	' |
	while read LEN GETFILENAME; do
		printf "Reading $GETFILENAME..." >&2
		mkdir -p `dirname "$GETFILENAME"`
		dd bs=1 count=$LEN > "$GETFILENAME" 2> /dev/null
		echo "done." >&2
	done

	cat "$EDITFILE" | grep "^diff " |
	while read LOCATION DATETIME CKSUM LEN FILENAME; do
		vimdiff "$LOCAL/$FILENAME" "$LOCAL/$FILENAME.remote"
	done

}

# echo "Comparing $LOCAL to $RHOST:$RDIR using $DIFFCOM ..."
echo "Comparing local to remote using \"$DIFFCOM\" ..."

"$DIFFCOM" "$TMPONE" "$TMPTWO" | tee "$TMPTHREE"
