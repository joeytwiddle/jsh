#!/bin/sh
# jsh-ext-depends-ignore: konqueror
# jsh-depends: jwhich xtermopts

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

# Find which xterm emulator we are going to use...
for xtermExeName in xterm x-terminal-emulator konqueror gnome-terminal dtterm NONE_FOUND
do

	## PROBLEM: This creates a forkbomb if you, say, symlink from ~/bin/xterm to here.
	# jwhich "$XTERME" >/dev/null && break ## unj because xterm is in :$JPATH:
	## What can we do?  Select last exe in $PATH?  :>
	## We could check realpath of this and callee, but they could still be different jsh installs.
	## This method also employed unj at the end

	## For now, we check any probable bin folders (at the moment we are only checking one - TODO):
	XTERME=/usr/bin/"$xtermExeName"
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
if [ "$VNCDESKTOP" = "X" ]
then
	## For low-res desktops.  Could we guess this from xdpyinfo?
	# XTERM_FONT='-b&h-lucidatypewriter-medium-r-normal-*-*-100-*-*-m-*-iso8859-1'
	# XTERM_FONT='-b&h-lucidatypewriter-medium-r-normal-*-11-*-*-*-m-*-iso8859-1'
	## These are these same, but seem weird - am I just used to Lucida?!
	# XTERM_FONT='-schumacher-clean-medium-r-normal-*-*-120-*-*-c-*-iso646.1991-irv'
	XTERM_FONT='-schumacher-clean-medium-r-normal-*-12-*-*-*-c-*-iso646.1991-irv'
fi

# XTERM_OPTS="$XTERM_OPTS -bg black -fg white"
## On a dark display, thin lines can be hard to see, so I lighten my background a bit.
## My monitor is kind-of dodgy, so this is nearly indistinguishable from black.
# XTERM_OPTS="$XTERM_OPTS -bg #081410 -fg white"
XTERM_OPTS="$XTERM_OPTS -bg #082222 -fg white"

## Cursor and pointer colors can be set in ~/.Xresources, and loaded with xrdb -merge.
# xterm*cursorColor: #ffdd44
# xterm*pointerColor: #ffee99

if [ "$XTERME" = xterm ]
then
	# XTERM_OPTS="$XTERM_OPTS `xtermopts`" ## gnome-terminal can't handle these, but it's ok if it's called as x-terminal-emulator (gnome-terminal.wrapper) in the newest gnome!
	XTERM_OPTS="$XTERM_OPTS -cc 33:48,37:48,45-47:48,64:48,126:48"
	XTERM_OPTS="$XTERM_OPTS -j -s -vb -si -sk"
	XTERM_OPTS="$XTERM_OPTS -rightbar +sb -sl 2000"
fi



# We used to have unj here
"$XTERME" -font "$XTERM_FONT" $XTERM_OPTS "$@" ## unj to prevent our xterm in :$JPATH:

