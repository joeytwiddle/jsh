cd "$JPATH/code/shellscript/" || exit 1

echo "Updating files from CVS ($JPATH/code/shellscript)"
cvsupdate -AdP

if test ! "$1" = "-quick"
then

	refreshtoollinks

	echo "jsh is up to date =)"

fi

