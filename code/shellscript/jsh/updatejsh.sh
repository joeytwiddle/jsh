cd "$JPATH/code/shellscript/" || exit 1

echo "Updating files from CVS ... ($JPATH/code/shellscript)"
cvsupdate -AdP

if [ ! "$1" = "-quick" ]
then

	echo "Relinking tool dir ... ($JPATH/tools)"
	refreshtoollinks

	if [ -d "$JPATH/code/home/" ]
	then
		if [ -f "$JPATH/code/home/.linkhome_auto" ]
		then
			echo "Updating .rc scripts since you have them ... ($JPATH/code/home)"
			cd "$JPATH/code/home/"
			cvsupdate -AdP
			echo "Relinking .rc scripts ... ($HOME)"
			linkhome
		else
			echo "Not auto-linking .rc scripts unless you touch $JPATH/code/home/.linkhome_auto"
		fi
	fi

	echo "Your jsh install is now up to date.  =)"

fi

