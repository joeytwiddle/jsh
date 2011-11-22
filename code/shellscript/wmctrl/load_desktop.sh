DESKTOP=` wmctrl -d | grep "[^ ]* *\*" | takecols 1 `

TARGET_DIR="$HOME/Desktop/OldSessions"
TARGET_FILE="$TARGET_DIR/$DESKTOP.session_sh"

if [ "$1" = -ask ]
then
	shift
	jshinfo "I will open the following windows:"
	echo
	cat "$TARGET_FILE"
	jshquestion "Do you want to do this [Y/n]? "
	read ANSWER
	if [ "$ANSWER" = y ] || [ "$ANSWER" = Y ] || [ "$ANSWER" = "" ]
	then load_desktop -go
	fi
	exit
fi

if [ "$1" = -go ]
then
	shift
	if [ -f "$TARGET_FILE" ]
	then
		( sh "$TARGET_FILE" ) &
		( sleep 10 ; mv "$TARGET_FILE" "$TARGET_FILE.restored" ) &
	else jshwarn "No desktop file: $TARGET_FILE"
	fi
	# sleep 10
	exit
fi

# /usr/bin/xterm -e load_desktop -ask
bigwin -fg load_desktop -ask

