#!/bin/sh

JPATH="$HOME/j"
export JPATH;

mkdir -p "$JPATH"
cd "$JPATH"

CVSROOT=":pserver:joey@hwi.ath.cx:/stuff/cvsroot"
export CVSROOT;
cvs login

mkdir code tools bin logs data tmp trash

echo "Checking out shellscripts and config files"

cd code
cvs checkout shellscript
cvs checkout home
cd ..

echo "Linking shellscripts into $JPATH/tools"

"$JPATH"/code/shellscript/init/refreshtoollinks

echo "You should put the following in your ~/.<preferredshell>rc:"
echo "JPATH=\"$JPATH\""
echo "export JPATH"
echo "source $JPATH/tools/startj-hwi"
echo "If the last line scares you, you may just do export PATH=\$JPATH/tools:\$PATH"
echo "You may also want to run linkhome"
