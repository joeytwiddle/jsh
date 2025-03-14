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

## The number of columns (fixed).
## For height 768px, 52 rows of lucida 13 fits closely, or 61 rows of lucida 11.
MANPOPUP_DESIRED_HEIGHT=52



REALMAN="`jwhich man`"
# INJ=`jwhich inj $1`
# REALMAN=/usr/bin/man
if [ ! -x "$REALMAN" ]
then
	echo "man not found! [$REALMAN]"
	exit 97
fi

## If user is using X-Windows, we pop up a new window for the manual page.
## If they are running inside screen, we open a new screen for the manual page.
## DONE: This caused problems when vnc was initialised from a screen, and had this variable exported to its children!  OK jsh has removed its export STY for the greater good.  Still, we could check X first, but that might feel odd when using screen under X, if DISPLAY is exported to the screen session.
if [ "$STY" ]
then screen -X screen -t '"'"$1"'"' $REALMAN -a "$@"
elif xisrunning && jwhich xterm >/dev/null 2>&1
then
	## Gah!  No matter what I do here, MANPOPUP_DESIRED_WIDTH is ignored, and the calling term's COLUMNS is used instead!
	## It is probably doing something like `tput cols` to get the number of columns, and ignore the COLUMNS variable.
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
	## BUG: I think we don't really need to do the caching if x is not running.
	##      This, and the sleep at the bottom, could be moved inside the xisrunning block below.
	##      NO!  The cache is useful to make 'catpage' efficient.  If we want to use catpage to list the headers, that functionality should be available in non-X situations too.  It should be named and refactored, and made optional (so we can use man and skip the cache if needed).  Use a hook function to perform the caching in advance.

	# [ "$INJ" ] && whitewin -title "jdoc $1" -geometry 80x"$MANPOPUP_DESIRED_HEIGHT" -e jdoc "$1"
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

		# whitewin -title "Manual: $*" -geometry "$WIDTH"x"$MANPOPUP_DESIRED_HEIGHT" -e $REALMAN -a "$@"
		# whitewin -title "Manual: $*" -geometry "$WIDTH"x"$MANPOPUP_DESIRED_HEIGHT" -e $REALMAN -a "$@"
		# whitewin -title "Manual: $*" -geometry "$WIDTH"x"$MANPOPUP_DESIRED_HEIGHT" -e $REALMAN -a "$@"

		## TODO: Detect if not in X, but in screen, then popup a screen tab like this:
		# whitewin -title "Manual: $*" -geometry "$WIDTH"x"$MANPOPUP_DESIRED_HEIGHT" -e inscreendo man $REALMAN -a "$@"

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

		# whitewin -title "Manual: $*" -geometry "$WIDTH"x"$MANPOPUP_DESIRED_HEIGHT" -e "less \"$cachedPage\""
		## Gah! Displaying our cached page with 'less' or with 'more' loses any bold/underline color modes set in .Xresources or by JMAN_SPECIAL_COLORS.  Has our cached copy dropped the bd/ul hints?  Or is less not showing them?
		## The colors work fine if we use man itself, and not our cached copy.
		whitewin -title "Manual: $*" -geometry "$WIDTH"x"$MANPOPUP_DESIRED_HEIGHT" -e "$REALMAN -a \"$*\""
		## FIXED: Because Ubuntu does not set the colors I want, we need a dark background...
		#bigwin "$REALMAN -a \"$*\""

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
## I think the original reason for this was in case window width (COLUMNS) changed.  That is no longer relevant.
#( sleep 120 ; rm "$cachedPage" ) &

