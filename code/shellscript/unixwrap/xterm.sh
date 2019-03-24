#!/bin/bash
# We cannot use /bin/sh here because it doesn't set HOSTNAME (dash)
# jsh-ext-depends-ignore: konqueror
# jsh-depends: jwhich

# No longer backgrounded - that should be done as shell alias.

# XTERME=`jwhich kterm`
# if test "$XTERME" = ""; then

## Just for fun, set the default xterm cursor to a random colour:
# COL=` for X in \`seq 1 6\`; do echolines \`seq 1 9\` a b c d e f | chooserandomline; done | tr -d '\n' `
# echo "XTerm*cursorColor: #$COL" | xrdb -merge

# XTERME=`jwhich xterm`
# [ "$XTERME" ] && [ ! "$XTERM_OPTS" ] && XTERM_OPTS=`xtermopts`
# [ ! "$XTERME" ] && XTERME=`jwhich konqueror`
# [ ! "$XTERME" ] && XTERME=`jwhich gnome-terminal` && XTERM_OPTS=""
# [ ! "$XTERME" ] && XTERME=`jwhich dtterm`

# # fi

favouriteTerms="xterm x-terminal-emulator gnome-terminal konqueror dtterm"

# Find which xterm emulator we are going to use...
for xtermExeName in $favouriteTerms NONE_FOUND
do

	## PROBLEM: This creates a forkbomb if you, say, symlink from ~/bin/xterm to here.
	# jwhich "$XTERME" >/dev/null && break ## unj because xterm is in :$JPATH:
	## What can we do?  Select last exe in $PATH?  :>
	## We could check realpath of this and callee, but they could still be different jsh installs.
	## This method also employed unj at the end

	## For now, we check any probable bin folders (at the moment we are only checking one - TODO):
	XTERME=/usr/bin/"$xtermExeName"   # Note the check below if you change this
	[ -x "$XTERME" ] >/dev/null && break

done



# Prepare options for terminal
# The following used to be in xtermopts but moved here.


# TODO: Select any bits from here that we might want to keep.  (Probably none.)
## Big:
# XTERM_FONT='-adobe-courier-medium-r-normal-*-*-140-*-*-p-*-iso8859-2'
## Thin big (wipeout):
# XTERM_FONT='-*-clean-medium-r-*-*-*-160-*-*-*-*-*-*'
## Medium:
# XTERM_FONT='-*-terminus-*-*-*-*-16-*-*-*-*-*-*-*' ## not so good bold
## Thin Lucida-style medium:
# XTERM_FONT="'-*-dejavu sans mono-medium-r-*-*-*-110-*-*-*-*-*-*'"
## Great small:
# XTERM_FONT='-*-clean-medium-r-*-*-*-120-*-*-*-*-*-*'
# XTERM_FONT='-*-terminus-*-*-*-*-12-*-*-*-*-*-*-*' ## taller with no cost to rowcount
## Some alternatives to "clean":
# XTERM_FONT='-*-proggysmalltt-*-*-*-*-*-120-*-*-*-*-*-*'   ## wider and shorter than clean
# XTERM_FONT='-*-montecarlo fixed 12-medium-r-*-*-*-120-*-*-*-*-*-*'   ## small and neat (1 pixel shorter than clean!), good bold, but weak 'a'
# XTERM_FONT='-*-modesevenfixed-*-*-*-*-12-*-*-*-*-*-*-*'



## This is the new font settings, that currently overrides anything done the above.
# XTERM_FONT='-*-dejavu sans mono-medium-r-*-*-*-110-*-*-*-*-*-*' ## Pretty big
# XTERM_FONT='-*-fixed-*-r-*-*-12-*-*-*-*-*-*-*' ## This one should work on all systems
# XTERM_FONT='-*-fixed-medium-r-*-*-13-*-*-*-*-*-*-*' ## This one should work on all systems
# XTERM_FONT='-b&h-lucidatypewriter-medium-r-normal-*-*-80-*-*-m-*-iso8859-1' ## My favourite for high dpi
## These stopped working for Debian:
# XTERM_FONT='lucidatypewriter-8'
# XTERM_OPTS="$XTERM_OPTS -fa lucidatypewriter-8"
## This still does tho:
XTERM_FONT='-b&h-lucidatypewriter-medium-r-normal-*-*-80-*-*-m-*-iso8859-1'
#XTERM_FONT='-b&h-lucidatypewriter-medium-r-normal-*-*-100-*-*-m-*-iso8859-1'
## One advantage of terminus is that unlike lucidatypewriter, it is there by default on most systems.
# XTERM_FONT='-*-terminus-*-*-*-*-16-*-*-*-*-*-*-*'
## Interestingly, I can get xterm to use fonts *not* visible in xfontsel, by passing:
# -fa "Liberation Mono" -fs 10
## This is not too bad, but still 1 pixel too tall for my liking.  For the classic lucidatypewriter, you DON'T need msttcorefonts, you need xfonts-75dpi or xfonts-100dpi.
## Although to get LucidaConsole in GVim, we need xfstt and lucon.ttf
## I wondered if we could use lucon.ttf for xterm too (although xfonts-??dpi seems preferable).  Under Ubuntu 12.10.04-LTS, GVim could see lucon through xfstt *without* needing to use TCP.  In fact if I did use TCP, and then xfontsel -scaled, my whole X crashed!

## Fun fact: zsh sets HOST but empties HOSTNAME, bash sets HOSTNAME but empties HOST, and /bin/sh sets neither!
## For Pod:
if [ "$HOSTNAME" = pod ]
then
	## Clean, like Terminus, is a cool/blocky shape.
	## At higher res I prefer fixed.
	## It uses more curves, which help the eye.
	# XTERM_FONT='-*-clean-medium-r-*-*-12-*-*-*-*-*-*-*'
	# XTERM_FONT='-*-clean-bold-r-*-*-13-*-*-*-*-*-*-*'   ## blocky - looks cool but bold is too bold
	# XTERM_FONT='-*-terminus-medium-r-*-*-*-140-*-*-*-*-*-*'   ## clean-15 looks cooler than terminus!
	# XTERM_FONT='-*-clean-medium-r-*-*-15-*-*-*-*-*-*-*' ## blocky - looks cool but not so easy on the eye
	XTERM_FONT='-*-fixed-medium-r-*-*-15-*-*-*-*-*-*-*'
fi
if [ "$HOSTNAME" = porridge ]
then XTERM_FONT='-b&h-lucidatypewriter-medium-r-normal-*-*-100-*-*-m-*-iso8859-1'
fi
if [ "$VNCDESKTOP" = "X" ]
then
	## For low-res desktops.  Could we guess this from xdpyinfo?
	# XTERM_FONT='-b&h-lucidatypewriter-medium-r-normal-*-*-100-*-*-m-*-iso8859-1'
	# XTERM_FONT='-b&h-lucidatypewriter-medium-r-normal-*-11-*-*-*-m-*-iso8859-1'
	## These are these same, but seem weird - am I just used to Lucida?!
	# XTERM_FONT='-schumacher-clean-medium-r-normal-*-*-120-*-*-c-*-iso646.1991-irv'
	XTERM_FONT='-schumacher-clean-medium-r-normal-*-12-*-*-*-c-*-iso646.1991-irv'
	# XTERM_FONT='-*-proggysmalltt-*-*-*-*-*-120-*-*-*-*-*-*'   ## wider and shorter than clean
fi

# These weren't working for ages - I only noticed -si (scroll on tty output) was missing!
if [ "$XTERME" = /usr/bin/xterm ]
then

	# XTERM_OPTS="$XTERM_OPTS -bg black -fg white"
	## On a dark display, thin lines can be hard to see, so I lighten my background a bit.
	## My monitor is kind-of dodgy, so this is nearly indistinguishable from black.
	# XTERM_OPTS="$XTERM_OPTS -bg #081410 -fg white"
	#XTERM_OPTS="$XTERM_OPTS -bg #082222 -fg white"
	#XTERM_OPTS="$XTERM_OPTS -bg #142828 -fg white"
	# What I used for a long time:
	#XTERM_OPTS="$XTERM_OPTS -bg #102626 -fg white"
	# What I use on Mac:
	#XTERM_OPTS="$XTERM_OPTS -bg #0b1a20 -fg #bbbbbb"
	# A little bit too blue
	#XTERM_OPTS="$XTERM_OPTS -bg #0b1a20 -fg #dddddd"
	# What I have been using in editors and on Mac
	XTERM_OPTS="$XTERM_OPTS -bg #102626 -fg #dddddd"
	# Compromise between them, a bit glowy grey
	#XTERM_OPTS="$XTERM_OPTS -bg #0e2020 -fg #dddddd"
	#XTERM_OPTS="$XTERM_OPTS -bg #0c1d1d -fg #dddddd"
	# Just right?
	#XTERM_OPTS="$XTERM_OPTS -bg #0b1a1c -fg #dddddd"

	## Cursor and pointer colors can be set in ~/.Xresources, and loaded with xrdb -merge.
	# xterm*cursorColor: #ffdd44
	# xterm*pointerColor: #ffee99

	# XTERM_OPTS="$XTERM_OPTS `xtermopts`" ## gnome-terminal can't handle these, but it's ok if it's called as x-terminal-emulator (gnome-terminal.wrapper) in the newest gnome!
	## -cc selection regions include () [] _ - . / exclude : ,
	XTERM_OPTS="$XTERM_OPTS -cc 33:48,37:48,45-47:48,64:48,126:48"
	#  +j = disable jumpScroll
	#       Without it scrolling is much slow, often causing a bottleneck.
	#       But I decided I don't mind waiting, so I can read what is going
	#       past, and have the opportunity to stop it if it is running
	#       incorrectly.  When I really need speed, I simply don't spam text.
	#       Nah re-enabled it.  Many progs spam (e.g. make) and I can't wait.
	#       If jumpScroll is enabled, it causes flicker, but is pretty fast.
	#  +s = asynchronous blit (does not cause flicker alone, if anyhing makes
	#       scroll speed appear smoother, at least on localhost)
	# -vb = visual bell
	# -si = no auto-scroll on output
	# -sk = auto-scroll on key
	XTERM_OPTS="$XTERM_OPTS -j -s -vb -si -sk"
	# -rightbar = obvious, +sb = hidden, -sl = history length
	XTERM_OPTS="$XTERM_OPTS -rightbar +sb -sl 8000"
	## Removed so that we can set the font through .Xresources or .Xresources.local
	# XTERM_OPTS="$XTERM_OPTS -font $XTERM_FONT"
fi


XTERM_OPTS="$XTERM_OPTS -geometry 90x24"


# We used to have unj here
exec "$XTERME" $XTERM_OPTS "$@" ## unj to prevent our xterm in :$JPATH:

