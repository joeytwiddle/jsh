#!/bin/sh

## TODO: make default /usr/local/jsh (if writable), otherwise ~/jsh preferable to ~/j ?!

## Quick install invocations (no argument passing):
## wget -O - http://hwi.ath.cx/installj | sh
## lynx -source http://hwi.ath.cx/installj | sh

## TODO: Rather than requesting arguments, should ask user.
## First question should be justdothedefault or choose -in -dev and -getrcs
## TODO: Make rc files an option.
## TODO: ability to checkout (and update) in absence of local cvs exe

## Default setup
# [ "$JPATH"   ] ||
JPATH="$HOME/j"
[ "$HWIUSER" ] || HWIUSER=anonymous

## Parsing user options
while [ "$1" ]
do
	case "$1" in
		"-in")
			JPATH="$2"
			shift
			shift
			## Ensure JPATH is _absolute_
			if [ ! `echo "$JPATH" | sed "s+^/.*$+ yep +"` = " yep " ]
			then JPATH="$PWD/$JPATH"
			fi
			continue
		;;
		"-dev")
			HWIUSER="$2"
			shift
			shift
			# echo "Note: if the machine you are installing on is not trusted,
			# you should not enter you password here, but instead login to hwi
			# using a trusted connection, cvs login there, and copy your
			# .cvspass from hwi to this box."
			# Nah soddit, .cvspass is a security risk anyway!
			continue
		;;
		*)
			echo "Usage:"
			echo "  $0 [ -in <directory> ] [ -dev <hwiusername> ]"
			echo "Defaults:"
			echo "  $0 -in \"\$HOME/j\" -dev anonymous"
			# echo "  $0 -in "$JPATH" -dev $HWIUSER"
			test "$*" && echo "Unparsed: $*"
			exit 1
		;;
	esac
	shift
done

test -d "$JPATH" &&
	echo "$JPATH already exists, please remove before installing here!" &&
	exit 1

## This pause is only useful if this script has been piped through wget.
sleep 1

export CVSROOT=":pserver:$HWIUSER@hwi.ath.cx:/stuff/cvsroot"

## Make initial CVS connection
if [ "$HWIUSER" = anonymous ]
then
	## Test if password already exists:
	if grep "^$CVSROOT" "$HOME/.cvspass" > /dev/null 2>&1
	then
		echo "Found anonymous password in $HOME/.cvspass =)"
	else
		## This is a cheat way to give the user a cvspass:
		echo "Adding anonymous password to $HOME/.cvspass"
		echo "/1 (null) A" >> "$HOME/.cvspass"
		echo "/1 $CVSROOT A" >> "$HOME/.cvspass"
	fi
else
	## TODO: check for it as above
	echo "First we need to login to Hwi's cvs as $HWIUSER,"
	echo "to obtain ~/.cvspass."
	test "$HWIUSER" = anonymous &&
		echo "Please use the password \"anonymous\""
	## Touch is important otherwise first time cvs(1.11.1p1debian-8.1)
	## labels server as null!  :-P
	touch $HOME/.cvspass
	cvs login ||
		exit 1
fi

echo "WARNING: this software comes with no warranty; \
you use it at your own risk; the authors accept no responsilibity."
echo "Now installing files to $JPATH."

## Create default tree

mkdir -p "$JPATH" && cd "$JPATH" ||
	exit 1

mkdir bin code data logs tmp tools trash

## Download code

cd code
echo "Checking out shellscripts"
cvs checkout shellscript | grep -v "^U "
if [ ! -d shellscript ]
then exit 1
fi
echo "Checking out rc files"
cvs checkout home | grep -v "^U "
# echo "Checking out C files"
# cvs checkout c
# echo "Checking out java files"
# cvs checkout java
cd ..
echo "Done downloading."
echo
cd ..
## Important to return to orig position because JPATH provided may
## be relative to user's original PWD

## Set up environment
export JPATH
echo "Linking shellscripts into $JPATH/tools (may take a while)"
"$JPATH"/code/shellscript/init/refreshtoollinks

## Finally, link the handy startup file
STARTFILE="$JPATH"/startj
ln -s "$JPATH"/tools/startj-hwi "$STARTFILE"
ln -s "$JPATH"/tools/startj-simple "$JPATH"
ln -s "$JPATH"/tools/jsh "$JPATH"

echo
echo "-------------------- Done installing. --------------------"
echo

echo "To start jsh manually, run $JPATH/jsh .  Then type jhelp for help."
echo
echo "To have jsh start automatically, add the following lines to your"
echo "~/.bash_profile or ~/.zshrc:"
### The following one-liners, and zsh simplification, are valid,
### but confusing, so removed:
# echo "To have jsh start automatically, do one the following:"
# echo "  For bash to ~/.bash_profile add \"$JPATH/jsh\""
# echo "  For zsh  to ~/.zshrc        add \". $JPATH/startj\""
# echo "  export JPATH=\"$JPATH\""
## echo "    (last line optional for zsh or if JPATH=$HOME/j)"
echo
echo "  export JPATH=\"$JPATH\""
# echo "  source \"$STARTFILE\""
echo "  source \"\$JPATH/startj\""
echo
echo "You may also want to run linkhome to link in some useful .rc files."
# echo "(Some interesting scripts: higrep, cvsdiff, monitorps, del,"
# echo "memo, onchange, findduplicatefiles, undelext2, b, et)"
echo

## Doesn't always work:
# sleep 2
# echo "Starting $JPATH/jsh now ..."
# $JPATH/jsh ||
	# echo "Oh no there was an error starting jsh!  Sorry." >&2

