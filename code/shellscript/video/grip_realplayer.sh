LISTFILE="$HOME/.jsh-rip_realplayer/streamurls.list"

## Create default config if none already exists
if [ ! -f "$LISTFILE" ]
then
mkdir -p $HOME/.jsh-rip_realplayer || exit
cat > "$LISTFILE" << !
http://news.bbc.co.uk/media/news_web/video/40545000/bb/40545855_bb_16x9.ram	BBC news
http://www.bbc.co.uk/newsa/n5ctrl/tvseq/newsnight/newsnight.ram	Newsnight
http://www.bbc.co.uk/newsa/n5ctrl/progs/question_time/latest.ram	Question time
http://www.bbc.co.uk/newsa/n5ctrl/progs/panorama/latest.ram	Panorama
!
fi

echo "Reading RealMedia resources from $LISTFILE"

[ "$DISPLAY" ] && DIALOG_PROG=Xdialog || DIALOG_PROG=dialog

while true
do

	## Build Dialog menu
	OPTIONS=`
		cat "$LISTFILE" |
		while read URL NAME
		do echo -n "\"$NAME\" \"$URL\" off "
		done
	`
	OPTIONS="$OPTIONS NEW \"Enter a new url\" on "
	OPTIONS="$OPTIONS CHANGE \"Change output directory (currently '$PWD')\" off "

	## Broken:
	# 'ls' "$PWD"/*.avi |
	# while read FILENAME
	# do OPTIONS="$OPTIONS \"WATCH_$FILENAME\" \"Change output directory (currently '$PWD')\" off "
	# done

	RESULT=` eval "$DIALOG_PROG --stdout --radiolist \"Which stream do you want to rip?\" 24 80 10 $OPTIONS" | tail -n 1 `

	if [ ! "$RESULT" ]
	then exit 1 # break
	fi

	echo "You chose: >$RESULT<"

	if [ "$RESULT" = NEW ]
	then
		if [ "$DIALOG_PROG" = Xdialog ]
		then
			INPUT=`$DIALOG_PROG --2inputsbox "Enter new RealMedia resource" 24 80 "Name of resource" "" "URL of resource" "http://.../something.ram" 2>&1`
			NAME=`echo "$INPUT" | beforefirst /`
			URL=`echo "$INPUT" | afterfirst /`
		else
			## TODO: Use a form!
			$DIALOG_PROG --inputbox "Enter name of stream" 10 30 "name" 2> /tmp/result.$$ ; NAME=`cat /tmp/result.$$`
			$DIALOG_PROG --inputbox "URL of resource" 10 30 "http://.../something.ram" 2> /tmp/result.$$ ; URL=`cat /tmp/result.$$`
		fi
		if [ "$NAME" ] && [ "$URL" ]
		then
			echo "$URL $NAME" >> "$LISTFILE"
		else
			echo "You must provide a URL and a name for the stream."
			sleep 4
		fi
		continue
	fi

	if [ "$RESULT" = CHANGE ]
	then
		# INPUT=`$DIALOG_PROG --dselect "Changing directory" 24 80 "" "" "URL of resource" "http://.../something.ram" 2>&1`
		# INPUT=`$DIALOG_PROG --fselect "$PWD" 20 60 2>&1` || exit
		$DIALOG_PROG --fselect "$PWD" 20 60 2>/tmp/result.$$ ; INPUT=`cat /tmp/result.$$`
		## BUG TODO : doesn't work!!
		echo "Changing directory to: $INPUT"
		sleep 2
		if [ -d "$INPUT" ]
		then cd "$INPUT"
		else error "Not a directory: $INPUT" ; sleep 2
		fi
		continue
	fi

	URL=`cat "$LISTFILE" | grep "$RESULT$" | beforefirst '[	 ]'`

	if [ "$DISPLAY" ]
	then guifyscript rip_realplayer "$URL"
	else rip_realplayer "$URL"
	fi
	# break

done
