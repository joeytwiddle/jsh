LISTFILE="$HOME/.jsh-rip_realplayer/streamurls.list"

## Create default config if none already exists
if [ ! -f "$LISTFILE" ]
then
mkdir -p $HOME/.jsh-rip_realplayer || exit
cat > "$LISTFILE" << !
http://www.bbc.co.uk/newsa/n5ctrl/tvseq/bb_news_ost.ram	BBC news
http://www.bbc.co.uk/newsa/n5ctrl/tvseq/newsnight/newsnight.ram	Newsnight
http://www.bbc.co.uk/newsa/n5ctrl/progs/question_time/latest.ram	Question time
http://www.bbc.co.uk/newsa/n5ctrl/progs/panorama/latest.ram	Panorama
!
fi

echo "Reading RealMedia resources from $LISTFILE"

while true
do

	## Build Dialog menu
	OPTIONS=`
		cat "$LISTFILE" |
		while read URL NAME
		do echo -n "\"$NAME\" \"$URL\" off "
		done
	`
	OPTIONS="$OPTIONS NEW \"enter a new url\" on "

	RESULT=`
	eval "Xdialog --radiolist \"Which stream do you want to rip?\" 24 80 10 $OPTIONS" 2>&1
	`

	if [ ! "$RESULT" ]
	then exit 1 # break
	fi

	echo "You chose: $RESULT"

	if [ "$RESULT" = NEW ]
	then
		INPUT=`Xdialog --2inputsbox "Enter new RealMedia resource" 24 80 "Name of resource" "" "URL of resource" "http://.../something.ram" 2>&1`
		NAME=`echo "$INPUT" | beforefirst /`
		URL=`echo "$INPUT" | afterfirst /`
		echo "$URL $NAME" >> "$LISTFILE"
		continue
	fi

	URL=`cat "$LISTFILE" | grep "$RESULT$" | beforefirst '[	 ]'`

	guifyscript rip_realplayer "$URL"
	# break

done
