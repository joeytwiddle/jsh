#!/bin/sh
## d: change directory and record for b and f shell tools
## Works for bash too despite its name!
## Although when .-ed without an argument in bash, it remembers the $1 from the last call!  :-(
## TODO:
# Shouldn't we remember moved-into, not moved-out-of?
# Sometimes NEWDIR="$@" breaks under ssh?
# Investigate: echo "($LAST)"

# NEWDIR="`expandthreedots "$*"`" ||
NEWDIR="$*"

# Record where we are for b and f sh tools
echo "$PWD" >> $HOME/.dirhistory

if [ -d "$NEWDIR" ]
then
	# The user specified a directory, plain and simple:
	'cd' "$NEWDIR"

elif [ "$NEWDIR" = "" ]
then
	# The user wants their homedir:
	# If I own the directory above ~, I prefer 'cd' to take me there.
	if [ `filename "$HOME"` = "$USER" ]
	then 'cd' "$HOME"
	else 'cd' "$HOME/.."
	fi

elif [ `echo "$NEWDIR" | sed 's+^\.\.\.[\.]*$+found+'` = found ]
then
	# The user asked for: cd ..... (...):
	# Allows user to say: cd foo/..../ba/......./bo where ...s become ../..
	# NOTE: Not for use by scripts, since if directory ... actually exists, case 1 above will execute instead of this
	NEWDIR="`expandthreedots "$NEWDIR"`"
	'cd' "$NEWDIR"

else
	## Directory does not exist, is not empty, and cannot be resolved with '...'s, so...
	
	# If incomplete dir given, check if there is a
	# unique directory which the user probably meant.
	# Useful substitue when tab-completion unavailable,
	# or with tab-completion which does not contextually exclude files.
	# NEWLIST=`echo "$NEWDIR"* 2>/dev/null |

	LOOKIN=`dirname "$NEWDIR"`
	LOOKFOR=`filename "$NEWDIR"`

	# Problem: 'ls' does not seem to override fakels alias on Solaris :-(
	NEWLIST=`
		'ls' -d "$LOOKIN/$LOOKFOR"* |
		while read X
		do [ -d "$X" ] && echo "$X"
		done
	` 2> /dev/null

	if [ "$NEWLIST" = "" ]
	then
		# No directory found:
		echo "X`cursered;cursebold` $LOOKIN/$LOOKFOR*`cursenorm`" # beep

	elif [ `echo "$NEWLIST" | countlines` = 1 ]
	then
		# One unique directory found  :)
		echo ">"`curseyellow`" $NEWLIST"`cursenorm`
		'cd' "$NEWLIST"

	else
		# Multiple possibilities, suggest them to the user.
		echo "$NEWLIST" |
		sed "s+^\(.*$NEWDIR\)\(.*\)$+? "`curseyellow`"\1"`curseyellow`"\2"`cursenorm`"+"

	fi

fi >&2

xttitle "$SHOWUSER$SHOWHOST$PWD %% "


## TODO: unreadable files / locked dirs
## TODO: accurate labeling of single/multiple
## TODO: "examine" mime-magic (see)
if [ "$LINUX_ADVENTURE" ]
then
	echo
	echo "`cursebold`You find yourself in $PWD"
	echo
	if [ "`find . -type f -maxdepth 1`" = "" ]
	then
		echo "`cursebold`Whatever might have been here has long since disappeared.`cursenorm`"
	else
		echo -n "You can see `cursenorm`"
		find . -type f -maxdepth 1 |
		foreachdo file |
		afterfirst : | beforefirst , |
		sed 's+\<ASCII ++' |
		sort | removeduplicatelines | randomorder |
		sed 's+^+some +' |
		sed 's+$+, +' |
		tr -d '\n'
		echo
	fi
	echo
	if [ "`find . -type d -maxdepth 1`" = '.' ]
	then
		echo "`cursebold`This is a dead end, but you can escape to`cursenorm` .."
	else
		echo -n "`cursebold`The maze extends deeper into `cursenorm`"
		find . -type d -maxdepth 1 |
		sed 's+^\./++' |
		tr '\n' ' '
		echo
	fi
	echo
	if [ "$PWD" = / ]
	then
		echo "`cursebold`You feel zen.`cursenorm`"
		echo
	fi
fi
