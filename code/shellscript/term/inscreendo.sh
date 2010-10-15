#!/bin/sh
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
	echo "  Always backgrounds.  (Just added that, hope it's fine!)"
	echo "  (However, it might block talking to an existing screen if screen has broken!)"
	echo
	echo "  Note: If the screen has already been created, then none of your current"
	echo "        environment will be passed to the called command.  You can only"
	echo "        pass it new command-line arguments.  But exports when you start"
	echo "        the first screen do get through."
	echo
	## How surprising I couldn't get screen to do this without this shellscript!
	exit 1
fi

if [ "$1" = -xterm ]
then INXTERM=true; shift
fi

SCRNAME="$1"
shift

## Is there already a screen with that name?
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
	then
		xterm -e screen -S "$SCRNAME" "$@" &
	else
		## TODO:
		# if live terminal
		# then screen -S "$SCRNAME" "$@"
		# else
		screen -d -m -S "$SCRNAME" "$@" &
		# fi
	fi

fi
