#!/bin/sh

## My script to popup vim in a new xterm with a sensible size for the file it is editing.
## Now runs recovervimswap first.

## One line version:
# xterm -title "[Vim] $*" -e vim "$@"

## BUG: Geometry estimation works badly on .gzipped files.  Either skip sizing or gunzip them!

if ! jwhich vim > /dev/null
then
	echo "[viminxterm] Failing: vim not found on PATH."
	exit 1
fi

## Meh fluxbox's grouping sucks anyway.  It won't do 1-group-per-desktop nor
## will it use most-recent-group, there will just be 1 global group.  =(
## If we are being called from an existing VIM session (let's assume it's in a terminal, not gvim).
## Then MYVIMRC, VIM or VIMRUNTIME are likely to be set.
if [ -n "$VIM" ] && which xdotool >/dev/null 2>&1
then
	getcurrentwindowtitle() {
		winid=`xdotool getwindowfocus`
		xwininfo -id "$winid" | grep "^xwininfo: " | sed 's+^[^"]*"++ ; s+"$++'
	}
	oldWindowTitle=`getcurrentwindowtitle`
	# jshinfo "oldWindowTitle=$oldWindowTitle"
	## This sneakily invites fluxbox to group the new window with the current
	## one, since my .fluxbox/apps file is configured to trigger a rule on this
	## title string:
	xttitle "Opening $* in Vim..."
	## This assumes your Vim will reset the xttitle again soon.
	## No it's ok, we will reset it here.  We must background this because the
	## xterm is called in foreground!
	(
		sleep 2
		# jshinfo "Restoring title $oldWindowTitle"
		xttitle "$oldWindowTitle"
	) &
fi

## TODO: this algorithm should be refactored out.  But how should it return /two/ values?  Source it or use it as a fn?  But it uses so many variables, we should ensure they are kept local.  Fn then, not direct sourcing.
## If the file exists, this cunning algorithm is used to determine the optimal dimensions for the editor window
## If the file needs more space than the maximum volume allowed, the algorithm prioritises height over width, but within limits.
## Alternative algorithm: Ideally we would ensure we get 95% of the lines fitting within the width of the terminal, but allow 5% of really long lines which we don't need to show in full.  But what if the longest 5% are only slightly longer than the rest, rather than grossly?  Ideally, we don't want the text to look "sparse" in the window when it pops up.
if [ -f "$1" ] && [ `filesize "$1"` != "0" ]
then

	MAX_ROWS_FOUND=0
	MAX_COLS_FOUND=0

	for FILE
	do

		## This is useful for editors like vim which unzip .gzipped files when they are opened.
		if endswith "$FILE" "\.gz"
		then
			FILETOREAD=`jgettmp viminxterm_"$FILE".unzipped`
			gunzip -c "$FILE" > "$FILETOREAD"
		else
			FILETOREAD="$FILE"
		fi

		ROWSINFILE=`countlines "$FILETOREAD"`
		COLSINFILE=`longestline "$FILETOREAD"`

		[ "$ROWSINFILE" -gt "$MAX_ROWS_FOUND" ] && MAX_ROWS_FOUND="$ROWSINFILE"
		[ "$COLSINFILE" -gt "$MAX_COLS_FOUND" ] && MAX_COLS_FOUND="$COLSINFILE"

		if [ ! "$FILETOREAD" = "$FILE" ]
		then jdeltmp $FILETOREAD
		fi

	done

	## Configuration, adjust to match your screen resolution and font size
	MAXVOL=`expr 140 "*" 50`
	MAXCOLS=160
	MAXROWS=56
	MINCOLS=20
	MINROWS=10

	## Expand the perceived dimensions of the file, so that the editor will show a little gap at the sides
	## Make room for MinBufExplorer, cmdheight, two statuslines and a little extra to make '~'s visible
	MAX_ROWS_FOUND=`expr '(' $MAX_ROWS_FOUND '+' 7 ')'`
	MAX_COLS_FOUND=`expr '(' $MAX_COLS_FOUND '+' 4 ')'`

	## Determine desired height, without exceeding needed height, or maximum allowed height
	if [ $MAX_ROWS_FOUND -lt $MAXROWS ]
	then ROWS=$MAX_ROWS_FOUND
	else ROWS=$MAXROWS
	fi

	## Determine largest possible width without exceeding maximum allowed volume
	COLS=`expr $MAXVOL / $ROWS`
	## Also, do not exceed needed width
	if [ $MAX_COLS_FOUND -lt $COLS ]
	then COLS=$MAX_COLS_FOUND
	fi
	## Also, do not exceed maximum allowed width
	if [ $COLS -gt $MAXCOLS ]
	then COLS=$MAXCOLS
	fi

	## And do not fall below minimum allowed width and height
	if [ $COLS -lt $MINCOLS ]
	then COLS=$MINCOLS
	fi
	if [ $ROWS -lt $MINROWS ]
	then ROWS=$MINROWS
	fi

else

	# Default size for new file
	COLS=80
	ROWS=45

fi

INTGEOM=`echo "$COLS"x"$ROWS" | sed 's|\..*x|x|;s|\..*$||'`

## This xterm title may eventually be overwritten by vim:
# TITLE=`absolutepath "$1"`" [vim-never-shown]"
# TITLE="[Vim] `basename "$1"` (`dirname "$1"`)"
## basename can fail with e.g. viminxterm -S oldsession5.vim
TITLE="[Vim] $1"
## Alternatively, -S could become a special case, with large COLS+ROWS defaults.

# XTFONT='-b&h-lucidatypewriter-medium-r-normal-*-*-80-*-*-m-*-iso8859-1';
# `jwhich xterm` -fg white -bg black -geometry $INTGEOM -font $XTFONT -title "$TITLE" -e vim "$@"

#font_args="-font -*-lucidatypewriter-medium-*-*-*-11-*-*-*-*-*-*-*"

# [ -f ~/.vim/plugin/session.vim ] && rm ~/.vim/plugin/session.vim

all_args_escaped="$(escapeargs "$@")"

## My personal preference is a classic x-terminal with a dark-grey/blue background.
# xterm -bg "#000048" -geometry $INTGEOM -title "$TITLE" -e vim "$@"
# xterm -bg "#000040" -geometry $INTGEOM -title "$TITLE" -e vim "$@"
# xterm -bg "#000040" -geometry $INTGEOM -title "$TITLE" -e recovervimswap -thenvim "$@"
# Fails on gnome-terminal: -bg "#223330" -geometry $INTGEOM -title "$TITLE" 
"$JPATH"/tools/xterm -geometry $INTGEOM -title "$TITLE" $font_args -e "$JPATH/tools/recovervimswap -thenvim $all_args_escaped"
# # XTERMOPTS=" -bg '#000040' -geometry $INTGEOM -title \"$TITLE\" "
# XTERMOPTS=" -bg '#000040' -geometry $INTGEOM " ## TITLE caused problems in my chroot (XTERMOPTS is not quoted)!
# if [ "`jwhich xterm`" ]
# then
	# `jwhich xterm` $XTERMOPTS -e recovervimswap -thenvim "$@" &
# else
	# [ "$XTERME" ] || XTERME=`jwhich konsole`
	# [ "$XTERME" ] || XTERME=`jwhich gnome-terminal`
	# # verbosely "$XTERME" -e "vim $*"
	# "$XTERME" -e "recovervimswap -thenvim $*" &
# fi

extcode=$?
# [ -f ~/.vim/plugin/session.vim ] && rm ~/.vim/plugin/session.vim
exit $extcode

