cd "$JPATH/code/shellscript/" || exit 1

echo "Updating files from CVS ... ($JPATH/code/shellscript)"
cvsupdate -AdP

if test ! "$1" = "-quick"
then

	refreshtoollinks

	if [ -d "$JPATH/code/home/" ]
	then
		cd "$JPATH/code/home/"
		cvsupdate -AdP
		linkhome
		echo "I have just dumped a load of crap in your home directory.  Hahahaha!"
	fi

	echo "your jsh install is so up to date that now we are really loving it =)"

fi

