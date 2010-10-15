#!/bin/sh
## I couldn't find a way for exim to accept the mail as if it was just received by exim and should be re-processed.
## I would have to talk SMTP for that, or maybe even that wouldn't work.  :-/

## BUG: adds extra headers each time round

## BUGS: formail appears to add an extra line at the bottom of each message (or is it only the last msg in each mbox?); this changes the message id :-/

## TODO: Could make $COMMAND a call back to eximrefiltermbox, which will only process mails matching user selection (eg. mail contains grep expression).

EXIM=/usr/sbin/exim
[ -x "$EXIM" ] || EXIM=/usr/sbin/exim4
if [ ! -x "$EXIM" ]
then
	error "Could not find exim or exim4"
	exit 1
fi

if [ "$UID" = 0 ]
then
	echo "Need to change \$USER in script to correct user innit."
	exit 1
fi

ONEMAIL_ON_STDIN=
if [ "$1" = -onemail ]
then ONEMAIL_ON_STDIN="-onemail"; shift
fi

TEST=
if [ "$1" = -test ]
then TEST="-test"; shift
fi

MBOX="$1"
[ "$MBOX" ] || MBOX=/tmp/mbox

if [ ! "$ONEMAIL_ON_STDIN" ]
then

	## They must have provided a mailbox; run once for each mail in it:
	cat "$MBOX" | formail -s eximrefiltermbox -onemail $TEST
	
	# |
	# highlight "^Save message to: .*"

else

	## We are going to process the email passed to us on standard input.

	# debug "$*"

	if [ "$TEST" ]
	then COMMAND="$EXIM -bf $HOME/.forward"
	else COMMAND="$EXIM -bm $USER"
	fi
	
	TMPFILE=`jgettmp email`

	# debug precat

	cat > "$TMPFILE"

	# debug postcat
	# set -x

	# debug "$COMMAND"

	jshinfo "Doing: $COMMAND"
	
	# cat "$TMPFILE" | $COMMAND
	# DEST=`cat "$TMPFILE" | $COMMAND`
	# | grep "^Save message to: .*" | sed 's/[^:]*: //'`
	DEST=`cat "$TMPFILE" | $COMMAND | pipeboth | grep "^Save message to: .*" | sed 's/[^:]*: //'`

	# debug postdest

	if [ "$DEST" ]
	then
		jshinfo "Exim decided to add to: $DEST"
		jshinfo "We could do this, eg.: ( cat \"$DEST\" ; cat \"$TMPFILE\" ) | dog \"$DEST\" but that doesn't lock the mailbox!"
		## ...
	fi

	jdeltmp "$TMPFILE"

fi

# ## I was worried it would add more headers, making the mails get long if repeated.
# ## But this dodgy method actually makes the headers shorter!
# 
# ## BUG: Breaks headers
# 
# . mailtools.shlib
# 
# COUNT=`mailcount`
# for N in `seq 1 $COUNT`
# do
# 
	# WHO=`getmail $N | grep "^From: " | head -n 1 | sed 's+From: ++'`
# 
	# echo "### $N <- $WHO"
# 
	# getmail $N |
	# grep -v "^boundary=\"" | ## headers still break.
	# grep -v "^From " | ## cos for some reason these were all marked the same, so I used $WHO instead.
# 
	# if [ "$TEST" ]
	# then $EXIM -f "$WHO" -bf ~/.forward
	# else $EXIM -f "$WHO" -bm $USER
	# fi
# 
	# echo
# 
# done
