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

	echo "Your jsh install is now up to date.  =)"
	echo

fi

