# jsh-ext-depends: screen
# jsh-depends: takecols xterm screen
## BUGS: Well, it's inconsistent: When rejoining an existing screen, it exits immediately.  But when creating a new screen, it blocks until the screen ends or is disconnected.  Behaviour should be made consistent, or optional.

if [ "$1" = "" ] || [ "$1" = --help ]
then
	echo
	echo "inscreendo [ -xterm ] <screen_name> <command>..."
	echo
	echo "  will either create or rejoin the named screen, and run the new command in it."
	echo
	echo "  If the screen does not already exist, the -xterm option will cause it to"
	echo "  start in a new xterm."
	echo
	echo "  Note: if the screen has already been created, then none of your existing"
	echo "        environment will be passed to the called command.  You can only hope"
	echo "        to pass it command-line arguments."
	echo
	## How surprising I couldn't get screen to do this without this shellscript!
	exit 1
fi

if [ "$1" = -xterm ]
then INXTERM=true; shift
fi

SCRNAME="$1"
shift

SCRSES=`screen -list | grep "$SCRNAME" | head -n 1 | takecols 1`

if [ "$SCRSES" ]
then

	## Connect to the screen:
	# screen -D -R "$SCRSES" -S "$SCRSES"

	## Run command in existing screen:
	screen -S "$SCRSES" -X screen "$@"
	## Set screen's title (niceity):
	screen -S "$SCRSES" -X title "[$*]"

else

	## Start a new screen with the command:
	if [ "$INXTERM" ]
	then xterm -e screen -S "$SCRNAME" "$@"
	else
		## TODO:
		# if live terminal
		# then screen -S "$SCRNAME" "$@"
		# else
		screen -d -m -S "$SCRNAME" "$@"
		# fi
	fi

fi
