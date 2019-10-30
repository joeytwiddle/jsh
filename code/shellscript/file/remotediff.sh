#!/bin/sh
# jsh-ext-depends-ignore: diff cksum host file time screen
# jsh-ext-depends: sed tar find sort column ssh
# jsh-depends: jfcsh debug cksum
# this-script-does-not-depend-on-jsh: edit jdeltmp jgettmp jdiff screen vimdiff error

### What started as "can i do it in three lines?" grew a bit larger...!
### remotediff and syncdiff used to be stand-alone (but this is no longer true: they use jgettmp at least!)
## and syncdiff requires jfcsh locally!

## Other dependencies locally: dd,sed,diff,cksum,sort,column,vi,ssh and jsh:jfcsh,cksum,vimdiff
## Remotely only a few are needed: sh, cat, dd, mkdir

## About to introduce tar dependency.  But it will bring less buggy transfer and preservation of times/perms.

## TODO: fork remotediff and syncdiff, and rename the latter (sync/merga?)!

## TODO: we should sort by filename (column 2) on the default cksum diffing, rather than sorting by cksum.

## TODO: add "ignore" command which will drop the filepath into the srcdir's .syncdiff.ignore file, and add approriate conditions to the find fn. when it is next run

syncdiffdoc () {
cat << !

syncdiff - a special diff command for remotediff which lets you edit a set of recommended file transfers and then performs them =)

  syncdiff presents a list of files, with the words send / bring / diff beside them.
  Delete the lines for actions you do not wish to perform, or edit them, then save and exit and the transfers will take place.
  Files for diffing will be brought locally, and the extension .from-<host> will be added.  That is all.
  You then need to type your password twice more for the transfers.  (TODO: these could be merged into one, but I wonder if we could keep the earlier ssh session open and reattach to it... )
  The remote machine must have find and cksum but doesn\'t need anything else.  Oh maybe it does need tar.

  TODO: We never actually create any diff lines, although the user can change the command.
        diff could be recommended for files present on both machines.
!
}

if ! which jgettmp >/dev/null 2>&1
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

syncdiff () {

	EDITFILE=`jgettmp remotediff.edit`
	jfcsh "$1" "$2" > "$1.only" # could factor in below if not used
	jfcsh "$2" "$1" > "$2.only"
	(
		echo "# This screen lists differences between the filestructure of the two directories."
		echo "# Delete actions (press dd) you do not wish to be taken, or change actions to one of:"
		echo "#   bring, send, diff,     ## TODO: del, delremote, ignore"
		echo "# Conflicting files are listed with the most recent first; one of the pair should be deleted."
		## TODO: compress conflicts into one command defaulting either to diff, bringow, or sendow.
		## TODO: if sync remembers when it was last run, or even the file details of when it was last run, it can tell whether one of the two files in a conflict has been unmodified, and can therefore safely default to be overwritten.
		(
			cat "$1.only" |
			while read X; do grep "$X$" "$1.longer"; done | ## TODO: assert exactly one match per X
			sed "s/^/send  /"
			cat "$2.only" |
			while read X; do grep "$X$" "$2.longer"; done | ## TODO: these "$X"s need to be escaped, eg. in case the filename contains '['
			sed "s/^/bring /"
		) |
		## Sort by date, then sort by path; so recent file should appear above the same older file:
		## Took out -s "stabilise sort" from second sort for tao
		sort -k 5 -k 2 |
		column -t -s '   '
	) > "$EDITFILE"

	vi "$EDITFILE"

	# DELCMD="del" # "rm -f"
# 
	# ATREMOTE=`
		# cat "$EDITFILE" | grep "^delremote " |
		# sed "s+^$AFIELD$AFIELD$AFIELD$AFIELD++" | ## TODO: factor out this call
		# sed "s+^+$DELCMD \"+;s+$+\"+"
	# `

	## TODO: error handling!
	## eg. Could put exit 1 instead of echo "ERROR"
	## better now

	export AFIELD="[^ 	]*[ 	]*"

	TOSEND=`
		cat "$EDITFILE" | grep "^send  " |
		sed "s+^$AFIELD$AFIELD$AFIELD$AFIELD++"
	`

	if [ ! "$TOSEND" ]
	then

		echo "No files to send."

	else

		SENDCMD="
			cd \"$LOCAL\"
			tar cz "`
					echo "$TOSEND" |
					sed "s+^+\"+;s+$+\" +" |
					tr -d '\n'
			`" |
			ssh -C $RUSER@$RHOST \"cd \\\"$RDIR\\\" && tar xz\"
		"

		echo "Hit <Enter> to send files with:"
		cursecyan
		echo "$SENDCMD" | sed 's+^[ 	]*++'
		cursenorm
		read OK

		eval "$SENDCMD"

	fi

	TOBRING=`
		cat "$EDITFILE" | grep "^\(bring\|diff\) " |
		sed "s+^$AFIELD$AFIELD$AFIELD$AFIELD++"
	`

	TOBRINGNODIFF=`
		cat "$EDITFILE" | grep "^bring" |
		sed "s+^$AFIELD$AFIELD$AFIELD$AFIELD++"
	`

	if [ ! "$TOBRING" ]
	then

		echo "No files to bring."

	else

		EXTRACTDIR=/tmp/syncdiff-incoming # "`echo "$LOCAL" | sed 's+[/]*$++'`-incoming"
		while [ -e "$EXTRACTDIR" ]
		do EXTRACTDIR="$EXTRACTDIR"_
		done

		mkdir -p "$EXTRACTDIR" || exit 1

		## TODO: factor out the cat $EDITFILE bit so we can check if its empty and skip if so (same for sending above)

		## ()s here retain PWD:
		BRINGCMD="
			(
			cd \"$EXTRACTDIR\"
			ssh -C $RUSER@$RHOST \"cd \\\"$RDIR\\\" && tar cz "`
					echo "$TOBRING" |
					sed "s+^+\\\\\\\\\"+;s+$+\\\\\\\\\" +" |
					tr -d '\n'
			`"\" |
			tar xz
			`
				if [ "$TOBRINGNODIFF" ]
				then
					echo "$TOBRINGNODIFF" |
					while read FILE
					do
						echo "mkdir -p \\\"$LOCAL/\`dirname "$FILE"\`\\\""
						echo "mv \\\"$EXTRACTDIR/$FILE\\\" \\\"$LOCAL/\`dirname "$FILE"\`\\\""
					done
				fi
			`
			)
		"

		echo "Hit <Enter> to bring files with:"
		cursecyan
		echo "$BRINGCMD" | sed 's+^[ 	]*++'
		cursenorm
		read OK

		eval "$BRINGCMD"

	fi

	DIFFSTODO=`
		cat "$EDITFILE" | grep "^diff " |
		while read ACTION DATETIME CKSUM LEN FILENAME
		# do echo "vimdiff \"$LOCAL/$FILENAME" "$LOCAL/$FILENAME.from-$RHOST"
		do echo "vimdiff \"$LOCAL/$FILENAME\" \"$EXTRACTDIR/$FILENAME\""
		done
	`

	if [ ! "$DIFFSTODO" ]
	then

		echo "No diffs to do."

	else

		echo "Hit <Enter> to diff files with:"
		cursecyan
		echo "$DIFFSTODO" | sed 's+^[ 	]*++'
		cursenorm
		read OK

		eval "$DIFFSTODO"

	fi

}



### remotediff - compare local and remote drectories

## User help:

if test ! $2 # --help
then
	echo
	echo "remotediff [ -diffcom <diff_command> ] <local-dir> <user>@<host>:<remote-dir> [ <find_options>... ]"
	echo
	echo "  shows the difference between local and remote directory trees, and optionally syncs differences."
	echo
	echo "Supported diff commands: (may alternatively be provided in \$DIFFCOM)"
	echo
	echo "  gvimdiff"
	echo "  vimdiff"
	echo "  jfc"
	echo "  jdiff"
	echo "  diff"
	echo "  syncdiff - Lets you edit diff list then transports files."
	echo
	echo "Note: wildcards in <find_options> should be double-quoted, eg: -name \"'*.txt'\""
	echo
	# syncdiffdoc
	exit 1
fi

### Read parameters:

if test "$1" = -diffcom
then
	DIFFCOM="$2"
	shift; shift
fi

LOCAL="$1"
LOCAL=`realpath "$LOCAL"` ## To deal with syncdiff bringing problems
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
# DIFFCOM="syncdiff"

### Set up commands for cksum retrieval:

FINDOPTS="-type f $1"
echo "Find options: $FINDOPTS"

CKSUMCOMEXT=""
if test "$DIFFCOM" = "syncdiff"; then
	## Note: this date is used for sorting later
	CKSUMCOMEXT='
		date "+%Y/%m/%d-%H:%M:%S" -r "$X" | tr -d "\n"
		printf " "
	'
fi

# cksum "$X"
CKSUMCOM='
	while read X; do
		'"$CKSUMCOMEXT"'
		## STILL TODO: get dos2unix invariability working (i dunno why ganymede/hwi differ so!  maybe it is svn not sending irrelevant whitespace.  could be)
		cksum "$X"
		# /home/joey/j/jsh filesize -likecksum "$X"
		## TODO: fix for dos/unix fs, dont know why it doesnt work
		cat "$X" | dos2unix | cksum - | tr -d "\n" && echo " $X"
		## Dunno why I thought it didnt work, or disabled it.  Test a bit more, then cleanup!
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

if [ "$DIFFCOM" = syncdiff ]
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



### Finally display the differences or start syncdiff:

# echo "Comparing $LOCAL to $RHOST:$RDIR using $DIFFCOM ..."
echo "Comparing local to remote using \"$DIFFCOM\" ..."

"$DIFFCOM" "$TMPONE" "$TMPTWO" # | tee "$TMPTHREE"
