#!/bin/sh

## Pops up the relevant man page in a new window (or in a new tab if using screen).
## Determines the maximum width of the man page in advance, so window can be appropriately sized.  (Some pages can be formatted very wide, whilst others seem fixed at 80.)

## DONE: Problems under Gentoo because memo is not caching because man returns non-zero exit code.
##       OK added fix to rememo, so it cats the cache whether the command succeeded or not.  (Seems appropriate!)

## If screen is running, could pop up in an extra window.  Could make this X/screen window popup functionality generic

## Option MANPOPUP_DESIRED_WIDTH - how wide do you want the window to be?
[ "$MANPOPUP_DESIRED_WIDTH" ] || MANPOPUP_DESIRED_WIDTH=120

## If man gives us not what we asked for, tries to fit to it
[ "$MANPOPUP_GUESS_WIDTH" ] || MANPOPUP_GUESS_WIDTH=true

## The max MANPOPUP_GUESS_WIDTH will expand to.
[ "$MANPOPUP_MAX_WIDTH" ] || MANPOPUP_MAX_WIDTH=200



REALMAN="`jwhich man`"
# INJ=`jwhich inj $1`
# REALMAN=/usr/bin/man
if [ ! -x "$REALMAN" ]
then
	echo "man not found! [$REALMAN]"
	exit 97
fi

## Gah!  No matter what I do here, MANPOPUP_DESIRED_WIDTH is ignored, and the calling term's COLUMNS is used instead!
# unset COLUMNS
COLUMNS="$MANPOPUP_DESIRED_WIDTH"
export COLUMNS
## OK so we'll just opt for a dirty fallback solution:  :P
# [ "$COLUMNS" ] && [ "$COLUMNS" -gt "$MANPOPUP_DESIRED_WIDTH" ] && MANPOPUP_DESIRED_WIDTH="$COLUMNS"

## Unfortunately memo is too damn slow =/
## So we make our own cache:
cachedPage="/tmp/manpopup.tmp.$$.joey"
rememo env COLUMNS="$MANPOPUP_DESIRED_WIDTH" "$REALMAN" -a "$@" > "$cachedPage"
catpage() {
	# memo "$REALMAN" -a "$@"   ## where "$@" were the parent script's args, not the functions
	cat "$cachedPage"
}
## BUG: One disadvantage of this, is that if we cannot write to /tmp/, we fail to display the man page!  memo might not do that

## If user is using X-Windows, we pop up a new window for the manual page.
## If they are running inside screen, we open a new screen for the manual page.
## DONE: This caused problems when vnc was initialised from a screen, and had this variable exported to its children!  OK jsh has removed its export STY for the greater good.  Still, we could check X first, but that might feel odd when using screen under X, if DISPLAY is exported to the screen session.
if [ "$STY" ]
then screen -X screen -t '"'"$1"'"' $REALMAN -a "$@"
elif xisrunning
then
	# [ "$INJ" ] && whitewin -title "jdoc $1" -geometry 80x60 -e jdoc "$1"
	## man will try to fit page within COLUMNS>=80plz, and then we will fit to whatever man outputs
	## First, check a manual page actually exists: (man will print error for us if not)
	if [ `catpage | wc -l` -gt 0 ]
	then

		if [ "$MANPOPUP_GUESS_WIDTH" ]
		then
			## We want to make the output as wide as the widest line:
			WIDTH=`catpage | col -bx | longestline`
			# jshinfo "WIDTH=$WIDTH"
			# WIDTH=`expr $WIDTH + 2`
			# [ "$WIDTH" -lt 10 ] && echo "col -bx | longestline failed" | tee -a "$JPATH/logs/jshdebug"
			[ "$WIDTH" -lt 20 ] && jshwarn "manpopup got WIDTH=$WIDTH"
			[ "$WIDTH" -lt 80 ] && WIDTH=80
			[ "$WIDTH" -gt "$MANPOPUP_DESIRED_WIDTH" ] && jshwarn "manpopup got WIDTH=$WIDTH"
			[ "$WIDTH" -gt "$MANPOPUP_MAX_WIDTH" ] && WIDTH="$MANPOPUP_MAX_WIDTH"
		else
			WIDTH="$MANPOPUP_DESIRED_WIDTH"
		fi

		# whitewin -title "Manual: $*" -geometry "$WIDTH"x60 -e $REALMAN -a "$@"
		# whitewin -title "Manual: $*" -geometry "$WIDTH"x60 -e $REALMAN -a "$@"
		# whitewin -title "Manual: $*" -geometry "$WIDTH"x60 -e $REALMAN -a "$@"

		## TODO: Detect if not in X, but in screen, then popup a screen tab like this:
		# whitewin -title "Manual: $*" -geometry "$WIDTH"x60 -e inscreendo man $REALMAN -a "$@"

		## Extract the first two levels of sections headings, to make a Table of Contents:
		## BUG: This means that now all the pages of -a are concatenated, rather than being able to move between them with :n :p.
		##      I would find this acceptable, IF we display at the very top which
		##      pages are being displayed, and clearly separate the transition
		##      between pages below.
		(
			catpage | grep "^\(\|   \)[A-Za-z]"
			echo
			catpage
		) |
		## Replace the cached copy:
		dog "$cachedPage"

		# whitewin -title "Manual: $*" -geometry "$WIDTH"x60 -e "less \"$cachedPage\""
		## Gah! Displaying our cached page with 'less' or with 'more' loses any bold/underline color modes set in .Xresources or by JMAN_SPECIAL_COLORS.  Has our cached copy dropped the bd/ul hints?  Or is less not showing them?
		## The colors work fine if we use man itself, and not our cached copy.
		whitewin -title "Manual: $*" -geometry "$WIDTH"x60 -e "$REALMAN -a \"$*\""

	fi
else
	$REALMAN -a "$@"
	# [ "$INJ" ] && jdoc "$1"
fi

## Always in terminal; looks for documentation within j project
# if test -x "$JPATH/tools/$1"
# then jdoc "$@"
# fi

## Ummm, so much for caching?
( sleep 120 ; rm "$cachedPage" ) &

