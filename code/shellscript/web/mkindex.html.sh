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
		echo "<TABLE>"

		cd "$DIR"
		find . -follow -type d -maxdepth 1 | sed 's+^..++' | sort |
		while read SUBDIR
		do echo "<TR><TD><A href=\"$SUBDIR\">$SUBDIR/</A></TD></TR>"
		done

		find . -follow -type f -maxdepth 1 | sed 's+^..++' | sort |
		while read FILE
		do
			SIZE=`filesize "$FILE"`
			DATE=`date -r "$FILE"`
			echo "<TR><TD><A href=\"$FILE\">$FILE</A></TD><TD align=\"right\">$SIZE</TD><TD>$DATE</TD></TR>"
		done

		echo "</TABLE>"
		echo "</BODY></HTML>"
	) > "$DIR"/index.html
done
