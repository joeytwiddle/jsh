echo "Changing to jsh root" &&

cd "$JPATH/code/shellscript/" &&

echo "Updating files from cvs" &&

cvsupdate -AdP &&

echo "Linking files into PATH" &&

refreshtoollinks &&

echo "jsh is up to date =)"
