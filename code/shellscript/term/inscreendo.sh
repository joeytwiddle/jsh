## Given <screen_name> and <command>, will either create or rejoin the named screen, and run the new command.
## How surprising I couldn't get screen to do this without this shellscript!

SCRNAME="$1"
shift

SCRSES=`screen -list | grep "$SCRNAME" | head -1 | takecols 1`

if [ "$SCRSES" ]
then

	screen -S "$SCRSES" -X screen "$@"
	screen -S "$SCRSES" -X title "==$*=="
	screen -D -R "$SCRSES" -S "$SCRSES"

else

	screen -S "$SCRNAME" "$@"

fi
