while read LINE
do
	if [ "$LINE" = "$*" ]
	then break
	else printf "%s\n" "$LINE"
	fi
done
