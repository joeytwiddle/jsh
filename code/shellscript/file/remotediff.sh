### remotediff and rsyncdiff are currently stand-alone =) (not true: they use jgettmp!)
## and rsyncdiff requires jfcsh locally!

## Other dependencies locally: dd,sed,diff,cksum,sort,column,vi,ssh and jsh:jfcsh,cksum,vimdiff
## Remotely only a few are needed: sh, cat, dd, mkdir

## TODO: we should sort by filename (column 2) on the default cksum diffing, rather than sorting by cksum.

rsyncdiffdoc () {
cat << !
rsyncdiff - a special diff command for remotediff which lets you edit a set of recommended file transfers and then performs them =)
  The remote machine must have find and cksum but doesn\'t need anything else.
  rsyncdiff presents a list of files, with the words send / bring / diff beside them.
  Delete the lines for actions you do not wish to perform, or edit them, then save and exit and the transfers will take place.
  Files for diffing will be brought locally, and the extension .from-<host> will be added.  That is all.
  You then need to type your password twice more for the transfers.  (TODO: these could be merged into one, but I wonder if we could keep the earlier ssh session open and reattach to it... )
  TODO: We never actually create any diff lines, although the user can change the command.
        diff could be recommended for files present on both machines.
!
}

if ! which jgettmp 2>&1 > /dev/null
then
	jgettmp () {
		echo "/tmp/$1.$$"
	}
	jdeltmp () {
		## TODO: Use it in the script then worth doing something here!
		# rm -f "$1"
		echo "Please delete: $1"
	}
fi

rsyncdiff () {

	EDITFILE=`jgettmp remotediff.edit`
	jfcsh "$1" "$2" > "$1.only"
	jfcsh "$2" "$1" > "$2.only"
	(
		cat "$1.only" |
		while read X; do grep "$X$" "$1.longer"; done | ## TODO: assert exactly one match per X
		sed "s/^/send  /"
		cat "$2.only" |
		while read X; do grep "$X$" "$2.longer"; done |
		sed "s/^/bring /"
	) |
	## Took out -s "stabilise sort" from second sort for tao
	sort -k 2 | sort -k 5 |
	column -t -s '   ' > "$EDITFILE"

	vi "$EDITFILE"

	## TODO: error handling!
	## eg. Could put exit 1 instead of echo "ERROR"

	## Send local files
	echo "[rsyncdiff] sending files to $RHOST" >&2
	cat "$EDITFILE" | grep "^send  " |
	while read LOCATION DATETIME CKSUM LEN FILENAME
	do
		echo "$LEN $RDIR/$FILENAME"
		cat "$LOCAL/$FILENAME"
	done |
	ssh -C $RUSER@$RHOST '
		while read LEN FILENAME
		do
			printf "Writing $FILENAME..." >&2
			mkdir -p `dirname "$FILENAME"`
			dd bs=1 count=$LEN > "$FILENAME" &&
			echo "done." >&2 ||
			echo "ERROR." >&2
		done
	'

	## Bring remote files and files for diffing
	echo "[rsyncdiff] bringing files from $RHOST" >&2
	(
		cat "$EDITFILE" | grep "^bring " |
		while read LOCATION DATETIME CKSUM LEN FILENAME
		do
			echo "$LEN $RDIR/$FILENAME"
			echo "$LOCAL/$FILENAME"
		done
		cat "$EDITFILE" | grep "^diff " |
		while read LOCATION DATETIME CKSUM LEN FILENAME
		do
			echo "$LEN $RDIR/$FILENAME"
			echo "$LOCAL/$FILENAME.from-$RHOST"
		done
	) |
	ssh $RUSER@$RHOST '
		while read LEN FILENAME
		do
			read GETFILENAME
			echo "$LEN $GETFILENAME"
			cat "$FILENAME"
		done
	' |
	while read LEN GETFILENAME
	do
		printf "Reading $GETFILENAME..." >&2
		mkdir -p `dirname "$GETFILENAME"`
		dd bs=1 count=$LEN > "$GETFILENAME" 2> /dev/null
		echo "done." >&2
	done

	## BUG TODO: vimdiff doesn't work because it's inside a pipe!
	# Could try running it inside a new bash?
	# or reading files=`...`

	cat "$EDITFILE" | grep "^diff " |
	while read LOCATION DATETIME CKSUM LEN FILENAME
	do vimdiff "$LOCAL/$FILENAME" "$LOCAL/$FILENAME.from-$RHOST"
	done

}



### remotediff - compare local and remote drectories

## User help:

if test ! $2 # --help
then
	echo
	echo "remotediff [ -diffcom <diff_command> ] <local-dir> <user>@<host>:<remote-dir> [ <find_options>... ]"
	echo
	echo "Supported diff commands: (may alternatively be provided in \$DIFFCOM)"
	echo
	echo "  gvimdiff"
	echo "  vimdiff"
	echo "  jfc"
	echo "  jdiff"
	echo "  diff"
	echo "  rsyncdiff - Lets you edit diff list then transports files."
	echo
	echo "Note: wildcards in <find_options> should be double-quoted, eg: -name \"'*.txt'\""
	echo
	# rsyncdiffdoc
	exit 1
fi

### Read parameters:

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

### Choose an available diff command:

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

### Set up commands for cksum retrieval:

FINDOPTS="-type f $1"
echo "Find options: $FINDOPTS"

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
REMOTECOM='cd "'"$RDIR"'" && eval "find . '"$FINDOPTS"'" | '"$CKSUMCOM"



### Get the cksums:

echo "Getting cksums for remote $RHOST:$RDIR"
debug ssh -C -l "$RUSER" "$RHOST" "$REMOTECOM" '>' "$TMPTWO.longer" "&&" echo "Got remote"
ssh -C -l "$RUSER" "$RHOST" "$REMOTECOM" > "$TMPTWO.longer" && echo "Got remote" &

echo "Getting cksums for local $LOCAL"
cd "$LOCAL" && eval find . $FINDOPTS | sh -c "$CKSUMCOM" > "$TMPONE.longer" && echo "Got local" &

wait



## Post-process results if required:

if [ "$DIFFCOM" = rsyncdiff ]
then
	## Removes the extra cksum (date) info to allow easier diffing
	# cat "$TMPONE.longer" | cut -d " " -f 2,3,4 > "$TMPONE"
	# cat "$TMPTWO.longer" | cut -d " " -f 2,3,4 > "$TMPTWO"
	cat "$TMPONE.longer" | sed 's+^[^ 	]*[ 	]*++' > "$TMPONE"
	cat "$TMPTWO.longer" | sed 's+^[^ 	]*[ 	]*++' > "$TMPTWO"
else
	cat "$TMPONE.longer" > "$TMPONE"
	cat "$TMPTWO.longer" > "$TMPTWO"
fi

# Some diffs work badly if not sorted:
preparefordiff () {
	sort -k 3 "$TMPONE" > "$TMPONE.sorted"
	sort -k 3 "$TMPTWO" > "$TMPTWO.sorted"
	## Wow these vars gets exported up to main flow:
	TMPONE="$TMPONE.sorted"
	TMPTWO="$TMPTWO.sorted"
}

if test "$DIFFCOM" = "diff" -o "$DIFFCOM" = "vimdiff" -o "$DIFFCOM" = "gvimdiff" -o "$DIFFCOM" = "jdiff"
then preparefordiff
fi

# Removing cksum columns for the different diff-ers:
# ( jfc "$TMPONE" "$TMPTWO" | ( takecols 5 || cat ) ) || ( diff "$TMPONE" "$TMPTWO" | ( takecols 1 4 || cat ) )



### Finally display the differences or start rsyncdiff:

# echo "Comparing $LOCAL to $RHOST:$RDIR using $DIFFCOM ..."
echo "Comparing local to remote using \"$DIFFCOM\" ..."

"$DIFFCOM" "$TMPONE" "$TMPTWO" # | tee "$TMPTHREE"
