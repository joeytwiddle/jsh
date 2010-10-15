#!/bin/sh
## BUG: In the past I have sometimes had problems failing to rebuild the links.
##      This can happen for example if $JPATH/tools is unattainable, or if refreshtoollinks (or some other vital script) has conflicts and will not run.
## TODO: One fix might be to build the new set of links and check them before replacing the old links with the new set.
##       Dunno what to do about cvs creating conflicts in required working scripts though...

cd "$JPATH/code/shellscript/" || exit 1

echo
echo "Updating shellscripts in $JPATH/code/shellscript from CVS"
cvsupdate -AdP
echo

if [ ! "$1" = "-quick" ]
then

	echo "Regenerating links from $JPATH/tools to $JPATH/code/shellscript/*"
	refreshtoollinks
	echo

	if [ -d "$JPATH/code/home/" ]
	then
		echo "Updating .rc scripts in $JPATH/code/home from CVS"
		cd "$JPATH/code/home/"
		cvsupdate -AdP || exit
		echo
		if [ -f "$JPATH/code/home/.linkhome_auto" ]
		then
			echo "Regenerating links from $HOME to $JPATH/code/home/* ..."
			linkhome
		else
			echo "Not auto-linking .rc scripts unless you touch $JPATH/code/home/.linkhome_auto"
		fi
		echo
	fi

	echo "Checking for post-checkout script $0.NEW"
	if [ -f "$0".NEW ]
	then . "$0".NEW
	fi

	echo "Your jsh install is now up to date.  =)"
	echo

fi

