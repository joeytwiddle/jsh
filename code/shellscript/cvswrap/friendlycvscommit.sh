#!/bin/bash
if [ "$1" = --help ]
then
cat << !

friendlycvscommit

  Easily commit cvs changes from the command line.  A visual diff of each file
  is shown, and the user is prompted for action.

  Pretty-prints diffs between your checkout and the repository, and allows you
  to comment and commit changes.

  Users who do not like the default diff output, might like to try instead:
    DIFFCOM="jdiffsimple -fine" friendlycvscommit

  Also: DONT_USE_FIGLET=1

!
exit 1
fi

getfiles () {
	#### Lists files which are handled by cvs (are in the repository).
	## This is very slow, could try: cvs diff 2>/dev/null | grep "^Index:"
	## I use memo to avoid locking problems caused by two cvs's querying the same directory.  Ie. I get the cvsdiff saved to a file (thanks to memo) before I do any commits.
	## TODO: this memo doesn't solve the problem!  cvs status: [07:42:00] waiting for joey's lock in /stuff/cvsroot/shellscript/memo
	## TODO: does it only happen after a commit?  I added a sleep below to try to fix the BUG.
		memo -t "30 seconds" cvsdiff -all "$@" |
			grep "^cvs commit " |
			sed 's+^cvs commit ++' |
			sed 's+[	 ]*#.*++'
	# drop 2 | chop 1 |
	# grep -v "^$" | grep -v "^#" |
}

function flatdiff () {
	diff "$@" | diffhighlight | more
	## We used to do this, but we can't rely on it if we don't do it for *every* file!
	# tee lastcvsdiff.out | 
	# -C 1 is nice for some context but then we never get <red >green lines, only !yellow changes, although with extra processing we could colour the !s correctly.
}

# jdiff asks us to export COLUMNS if we haven't.  Desirable if terminal width is not 80.
# But doing it here doesn't work!  Seems we have to do it in the user shell.  :P
# export COLUMNS="$COLUMNS"
[ ! "$COLUMNS" ] && jshwarn "You probably want to export COLUMNS and re-run."   # (I can't do it for you, I've tried!)
[ "$DIFFCOM" ] || DIFFCOM="jdiff"
# [ "$DIFFCOM" ] || DIFFCOM="flatdiff"

## First, choose a figlet font:
if [ ! "$DONT_USE_FIGLET" ]
then
	export DONT_USE_FIGLET=true
	if jwhich figlet quietly
	then
		for FIGLET_FONT in small straight stampatello italic mini short ogre
		do
			# FIGLET_FONT_FILE=`unj locate "$FIGLET_FONT.flf" | head -n 1`
			FIGLET_FONT_FILE=`MEMO_IGNORE_DIR=true memo unj locate "$FIGLET_FONT.flf" | grep "\.flf$" | head -n 1`
			if [ "$FIGLET_FONT_FILE" ]
			then
				export DONT_USE_FIGLET=
				# echo "Will use figlet font: $FIGLET_FONT_FILE"
				break
			fi
		done
	fi
fi

## TODO: if a file needs /updating/ then just print a message saying so.  =)

function tinydiffsummary() {
	if [ -f lastcvsdiff.out ]
	then
		COUNTREMOVED=`cat lastcvsdiff.out | grep "^<" | wc -l`
		COUNTADDED=`cat lastcvsdiff.out | grep "^>" | wc -l`
		echo "-$COUNTREMOVED +$COUNTADDED"
	fi
}

shift ## ?
FILES=`getfiles "$@"`
TMPFILE=`jgettmp "repository_version"`
for FILE in $FILES
do
	if [ ! -f "$FILE" ]
	then error "skipping non-file: $FILE"; continue
	fi

	(

		(

			cursemagenta ; cursebold
			if [ "$FIGLET_FONT_FILE" ]
			then
				figlet -w "$COLUMNS" -f "$FIGLET_FONT_FILE" "$FILE"
			else
				echo "File: `cursecyan``cursebold`$FILE`cursenorm`"
			fi

			# cursecyan
			cursenorm ; cursemagenta
			cvs status "$FILE"
			cursenorm

			# curseblue
			## TODO: this is the cvs status that blocks, because it's directory is locked.
			# cvs status "$FILE" | highlight "^File:.*" cyan

			# cvs diff "$FILE"

			cvs -q update -p "$FILE" > $TMPFILE 2>/dev/null

		) # | trimempty

		$DIFFCOM $TMPFILE "$FILE"

	) | more

	echo
	while true
	do
		# echo "Provide a comment with which to commit `cursecyan`$FILE`curseyellow`, or <Enter> to skip.  ('.<Enter>' will commit empty comment.)"
		# echo "`curseyellow`Type: comment or [.] to [C]ommit, <Enter> to [S]kip, [E]dit [V]imdiff [R]ediff." #  (.=\"\").`cursenorm`"
		echo "`cursecyan`$FILE`cursenorm`"
		echo "`cursecyan;cursebold`Type comment or [.] to [C]ommit | <Enter> to [S]kip | [E]dit [V]imdiff [R]ediff [F]latdiff" #  (.=\"\").`cursenorm`"
		echo "Or [U]ndo changes (retrieve previous version) | [Q]uit`cursenorm`"
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
				$DIFFCOM $TMPFILE "$FILE" | more
			;;
			f|F)
				flatdiff $TMPFILE "$FILE" | more
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
			q|Q)
				echo "Aborting friendlycvscommit at user request."
				exit 0
			;;
			c|C|.|????*)
				# [ "$INPUT" = "." ] || [ INPUT = c ] || [ INPUT = C ] && INPUT=""
				# [ "$INPUT" = "." ] || [ INPUT = c ] || [ INPUT = C ] && INPUT="Commited from `hostname`:`realpath "$FILE"`"
				# [ "$INPUT" = "." ] || [ INPUT = c ] || [ INPUT = C ] && INPUT="`whoami`@`hostname`:`realpath .`"
				[ "$INPUT" = "." ] || [ INPUT = c ] || [ INPUT = C ] && INPUT="`whoami`@`hostname` `tinydiffsummary "$FILE"` `date +"%Y/%m/%d %H:%M %Z" -r "$FILE"`"
				echo "`cursegreen`Committing with comment:`cursenorm` $INPUT"
				echo "`cursecyan`cvscommit -m \"$INPUT\" $FILE`cursenorm`"
				cvscommit -m "$INPUT" "$FILE" ||
				error "cvscommit failed!"
				sleep 5 ## attempt to fix lock BUG ## NOPE!!!
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
[ -f lastcvsdiff.out ] && rm -f lastcvsdiff.out

