if [ "$1" = -r ]
then
	shift
	find "$@" -type d |
	foreachdo verbosely mkindex.html
	exit
fi

if [ ! "$1" ]
then mkindex.html . ; exit
fi

for DIR
do
	[ -e "$DIR"/index.html ] && del "$DIR"/index.html
	(
		echo "<HTML>"
		echo "<HEAD>"
		echo "<TITLE>Index of <javascript>document.location</javascript></TITLE>"
		echo "</HEAD>"
		echo "<BODY>"
		echo "<H1>Index of <javascript>document.location</javascript></H1>"

		cd "$DIR"
		find . -type d -maxdepth 1 | sed 's+^..++' |
		while read SUBDIR
		do echo "<A href=\"$SUBDIR\">$SUBDIR/</A><BR>"
		done

		find . -type f -maxdepth 1 | sed 's+^..++' |
		while read FILE
		do
			SIZE=`filesize "$FILE"`
			DATE=`date -r "$FILE"`
			echo "<A href=\"$FILE\">$FILE</A> ($SIZE) $DATE<BR>"
		done

		echo "</BODY></HTML>"
	) > "$DIR"/index.html
done
