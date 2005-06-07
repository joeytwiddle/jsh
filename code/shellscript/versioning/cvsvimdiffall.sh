## jsh-help: Vimdiffs each file which differs from its copy in the repository.  If user writes file (changes date), then file is committed.

## This is/was a copy of what is in friendlycvscommit
getfiles () {
	## This is very slow, could try: cvs diff 2>/dev/null | grep "^Index:"
	## I use memo to avoid locking problems caused by two cvs's querying the same directory.  Ie. I get the cvsdiff saved to a file (thanks to memo) before I do any commits.
	## TODO: this memo doesn't solve the problem!  cvs status: [07:42:00] waiting for joey's lock in /stuff/cvsroot/shellscript/memo
	## TODO: does it only happen after a commit?  I added a sleep below to try to fix the BUG.
	memo -t "30 seconds" cvsdiff "$@" |
	grep "^cvs commit " |
	sed 's+^cvs commit ++' |
	sed 's+[	 ]*#.*++'
	# drop 2 | chop 1 |
	# grep -v "^$" | grep -v "^#" |
}


FILES=`getfiles "$@"`
STARTTIME=`jgettmp cvsvimdiff-watchchange`
ORIGFILETIME=`jgettmp cvsvimdiff-watchchange`
touch "$STARTTIME"
## Doesn't handle spaces
## But with previous while read vim complained input not from term (outside X)
## Now we sometimes get (but successfully ignore) cvs errors in the filelist: "Repository revision: No revision control file"
for FILE in $FILES
do
	echo
	if [ ! -f "$FILE" ]
	then error "skipping non-file: $FILE"; continue
	fi
	touch -r "$FILE" "$ORIGFILETIME"
	if ! cvsvimdiff "$FILE" # doesn't work sometimes: > /dev/null 2>&1
	then
		echo
		error "cvsvimdiff exited badly"; continue
	fi
	echo
	if newer "$FILE" "$STARTTIME"
	then
		cursegreen; cursebold
		echo "Committing $FILE"
		cursenorm
		echo
		## Reset file's time to that which it had before cvsvimdiff
		touch -r "$ORIGFILETIME" "$FILE"
		cvscommit -m "" "$FILE"
	else
		curseyellow
		echo "Not committing $FILE"
		cursenorm
	fi
done
jdeltmp $STARTTIME $ORIGFILETIME


