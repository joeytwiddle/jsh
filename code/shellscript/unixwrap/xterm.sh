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

for XTERME in xterm x-terminal-emulator konqueror gnome-terminal dtterm NONE_FOUND
do jwhich "$XTERME" >/dev/null && break ## unj because xterm is in :$JPATH:
done

# XTERM_FONT='-*-dejavu sans mono-medium-r-*-*-*-110-*-*-*-*-*-*' ## Pretty big
# XTERM_FONT='-*-fixed-*-r-*-*-12-*-*-*-*-*-*-*' ## This one should work on all systems
# XTERM_FONT='-*-fixed-medium-r-*-*-13-*-*-*-*-*-*-*' ## This one should work on all systems
# XTERM_FONT='-b&h-lucidatypewriter-medium-r-normal-*-*-80-*-*-m-*-iso8859-1' ## My favourite for high dpi
## These stopped working for Debian:
# XTERM_FONT='lucidatypewriter-8'
# XTERM_OPTS="$XTERM_OPTS -fa lucidatypewriter-8"
## This still does tho:
XTERM_FONT='-b&h-lucidatypewriter-medium-r-normal-*-*-80-*-*-m-*-iso8859-1'

# XTERM_OPTS="$XTERM_OPTS -bg black -fg white"
# XTERM_OPTS="$XTERM_OPTS -bg black -fg #e0e0e0"
XTERM_OPTS="$XTERM_OPTS -bg black -fg #ffffe0"
# XTERM_OPTS="$XTERM_OPTS -bg black -fg #ccccaa"

if [ "$XTERME" = xterm ]
then
	# XTERM_OPTS="$XTERM_OPTS `xtermopts`" ## gnome-terminal can't handle these, but it's ok if it's called as x-terminal-emulator (gnome-terminal.wrapper) in the newest gnome!
	XTERM_OPTS="$XTERM_OPTS -cc 33:48,37:48,45-47:48,64:48,126:48"
	XTERM_OPTS="$XTERM_OPTS -j -s -vb -si -sk"
	XTERM_OPTS="$XTERM_OPTS -rightbar +sb -sl 2000"
fi

unj "$XTERME" -font "$XTERM_FONT" $XTERM_OPTS "$@" ## unj to prevent our xterm in :$JPATH:

