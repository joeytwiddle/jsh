# jsh-depends-ignore: vimdiff
# jsh-depends: cursebold cursecyan cursegreen curseyellow cursenorm cvsdiff cvsedit cvsvimdiff edit jdeltmp jgettmp jdiff newer error

if [ ! "$DONT_USE_FIGLET" ]
then
	if jwhich figlet quietly
	then
		for FIGLET_FONT in straight stampatello italic mini short ogre
		do
			FIGLET_FONT_FILE=`unj locate "$FIGLET_FONT.flf" | head -1`
			if [ "$FIGLET_FONT_FILE" ]
			then break
			fi
		done
	fi
fi

getfiles () {
	## This is very slow, could try: cvs diff 2>/dev/null | grep "^Index:"
	cvsdiff "$@" |
	grep "^cvs commit " |
	sed 's+^cvs commit ++' |
	sed 's+[	 ]*#.*++'
	# drop 2 | chop 1 |
	# grep -v "^$" | grep -v "^#" |
}

## If we can leave it out, it lets us resize during run:
# export COLUMNS

if [ "$1" = "-diff" ]
then

	## TODO: if a file needs /updating/ then just print a message saying so.  =)

	shift
	FILES=`getfiles "$@"`
	TMPFILE=`jgettmp "repository_version"`
	for FILE in $FILES
	do
		if [ ! -f "$FILE" ]
		then error "skipping non-file: $FILE"; continue
		fi
		(
			## TODO: optionally use figlet with font here!
			(
			curseblue
			cvs status "$FILE"
			# cvs diff "$FILE"
			cvs -q update -p "$FILE" > $TMPFILE 2>/dev/null
			cursenorm
			if [ "$FIGLET_FONT_FILE" ]
			then
				cursecyan
				figlet -w "$COLUMNS" -f "$FIGLET_FONT_FILE" "$FILE"
				cursenorm
			else
				echo "File: `cursecyan``cursebold`$FILE`cursenorm`"
			fi
			) | trimempty
			# jdiff "$TMPFILE" $FILE
		# )
			jdiff -infg $TMPFILE "$FILE"
		) | more
		echo
		while true
		do
			# echo "Provide a comment with which to commit `cursecyan`$FILE`curseyellow`, or <Enter> to skip.  ('.<Enter>' will commit empty comment.)"
			# echo "`curseyellow`Type: comment or [.] to [C]ommit, <Enter> to [S]kip, [E]dit [V]imdiff [R]ediff." #  (.=\"\").`cursenorm`"
			echo "`cursecyan;cursebold`Type comment or [.] to [C]ommit | <Enter> to [S]kip | [E]dit [V]imdiff [R]ediff" #  (.=\"\").`cursenorm`"
			echo "Or [U]ndo changes (retrieve previous version)`cursenorm`"
			read INPUT
			[ "$INPUT" = "" ] && INPUT=s
			case "$INPUT" in
				e|E)
					edit "$FILE"
				;;
				v|V)
					vimdiff "$FILE" $TMPFILE
				;;
				r|R|d|D)
					jdiff -infg $TMPFILE "$FILE" | more
				;;
				s|S)
					echo "`cursegreen`Skipping:`cursenorm` $FILE"
					break
				;;
				u|U)
					del "$FILE"
					cvs update "$FILE"
					cvs edit "$FILE" # that's the way i like it ;)
					break
				;;
				c|C|.|????*)
					[ "$INPUT" = "." ] || [ INPUT = c ] || [ INPUT = C ] && INPUT=""
					echo "`cursegreen`Committing with comment:`cursenorm` $INPUT"
					echo "`cursecyan`cvscommit -m \"$INPUT\" $FILE`cursenorm`"
					cvscommit -m "$INPUT" "$FILE" ||
					error "cvscommit failed!"
					break
				;;
				?|??|???)
					error "Will not accept such a small comment - assuming user error."
				;;
				*)
					error "$0: This should never happen"
				;;
			esac
		done
		echo
	done
	jdeltmp $TMPFILE

elif test "$1" = "-vimdiff"
then

	shift
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

else

	cvs -q commit "$@"
	# | grep -v "^? "
	## caused: "Vim: Warning: Output is not to a terminal"
	cvsedit "$@" 2> /dev/null

fi
