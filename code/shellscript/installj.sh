#!/bin/sh

## Default setup
export JPATH="$HOME/j"
HWIUSER=anonymous

## Parsing user options
while test "$1"
do
	case "$1" in
		"-in")
			shift
			JPATH="$1"
		;;
		"-devel")
			shift
			HWIUSER="$1"
		;;
		*)
			echo "$0 [ -in <directory> ] [ -devel <hwiusername> ]"
			echo "  Default is:"
			echo "    $0 \"\$HOME/j\" \"anonymous\""
			echo "  Possible invocations:"
			echo "    wget -O - http://hwi.ath.cx/installj | sh"
			echo "    lynx --source http://hwi.ath.cx/installj | sh"
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

## Make initial CVS connection
export CVSROOT=":pserver:$HWIUSER@hwi.ath.cx:/stuff/cvsroot"
# Test if password already exists.
if ! grep "^$CVSROOT" "$HOME/.cvspass" > /dev/null 2>&1; then
	echo "Initial login to Hwi as $HWIUSER, to obtain ~/.cvspass."
	test "$HWIUSER" = "anonymous" && echo "Please use password: anonymous"
	cvs login ||
		exit 1
fi

echo "WARNING: this software comes with no warranty; you use it at your own risk; the authors accept no responsilibity."
echo "Now installing files to $JPATH."

## Create default tree

mkdir -p "$JPATH" && cd "$JPATH" ||
	exit 1

mkdir bin code data logs tmp tools trash

## Download code

cd code
echo "Checking out shellscripts"
cvs checkout shellscript | grep -v "^U "
echo "Checking out rc files"
cvs checkout home | grep -v "^U "
# echo "Checking out C files"
# cvs checkout c
# echo "Checking out java files"
# cvs checkout java
cd ..
echo "Done downloading."
echo

## Set up environment
echo "Linking shellscripts into $JPATH/tools (may take a while)"
"$JPATH"/code/shellscript/init/refreshtoollinks

## Finally, link the handy startup file
STARTFILE="$JPATH"/startj
ln -s "$JPATH"/tools/startj-hwi "$STARTFILE"
ln -s "$JPATH"/tools/startj-simple "$STARTFILE"-simple

echo "Done installing."
echo

echo "You may now put the following line in your ~/.<preferredshell>rc:"
echo "  source \"$STARTFILE\""
echo "or just run it by hand to try out the environment."
echo "If that doesn't work, try this beforehand:"
echo "  export JPATH=\"$JPATH\""
echo "(You may also want to run linkhome to use my .rc files)"
echo "(Some interesting scripts: higrep, cvsdiff, monitorps, del, memo, findduplicatefiles, undelext2, b, et)"
echo
