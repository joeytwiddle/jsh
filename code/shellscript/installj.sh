#!/bin/sh

# Change this to whatever you desire ($HOME/.j is a good alternative!)
# (actually with bash this does not quite work yet (your startup would need to be a two-liner until I write jsh...)
export JPATH="$HOME/j"

test -d "$JPATH" &&
	echo "$JPATH already exists, please remove before installing!" &&
	exit 1

echo "Will try to log you into Hwi's CVS as USER=$USER"
export CVSROOT=":pserver:$USER@hwi.ath.cx:/stuff/cvsroot"
cvs login ||
	(
		echo "OK giving you read-only access, please use password \"anonymouos\""
		export CVSROOT=":pserver:$USER@hwi.ath.cx:/stuff/cvsroot"
		cvs login
	) || exit 1

mkdir -p "$JPATH" && cd "$JPATH" ||
	exit 1

mkdir bin code data logs tmp tools trash

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

echo "Linking shellscripts into $JPATH/tools (may take a while)"
"$JPATH"/code/shellscript/init/refreshtoollinks

# Link a handy startup file
STARTFILE="$JPATH"/startj
ln -s "$JPATH"/tools/startj-hwi "$STARTFILE"

echo "Done installing."
echo

echo "You should put the following in your ~/.<preferredshell>rc:"
echo "  source \"$STARTFILE\""
echo "or just run it by hand to try out the environment."
# echo "If that scares you too much, try just:"
# echo "  export JPATH=\"$JPATH\""
# echo "  export PATH=\$JPATH/tools:\$PATH"
echo "(You may also want to run linkhome to use my .rc files)"
echo "(Some other interesting scripts: higrep, cvsdiff, monitorps, del, et)"
echo
