#!/bin/sh

# #!/bin/bash
# Works for bash too despite its name!

# d: change directory and record for b and f shell tools

# Shouldn't we remember moved-into, not moved-out-of?

# Sometimes NEWDIR="$@" breaks under ssh!

NEWDIR="$@"

# Record where we are for b and f sh tools
echo "$PWD" >> $HOME/.dirhistory

if test -d "$NEWDIR"; then

	# The user specified a directory, plain and simple.

	'cd' "$NEWDIR"

elif test "$NEWDIR" = ""; then

	# I prefer the directory above my home if I have multiple ~ directories.

	if test `filename "$HOME"` = "$USER"; then
		'cd' "$HOME"
	 else
		'cd' "$HOME/.."
	fi
	# 'cd'

elif test `echo "$NEWDIR" | sed 's+^\.\.\.[\.]*$+found+'` = "found"; then

	# The user asked for: cd ..... (...)

	cd `echo "$NEWDIR" | sed 's+^\.++;s+\.+../+g'`
	# Todo: allow user to say: cd foo/..../ba/......./bo

else
	
	# If incomplete dir given, check if there is a
	# unique directory which the user probably meant.
	# Useful substitue when tab-completion unavailable,
	# or with tab-completion which does not contextually exclude files.
	# NEWLIST=`echo "$NEWDIR"* 2>/dev/null |

	LOOKIN=`dirname "$NEWDIR"`
	LOOKFOR=`filename "$NEWDIR"`

	# Problem: 'ls' does not seem to override fakels alias on Solaris :-(
	NEWLIST=`
		# maxdepth does not work for Unix find!
		# find "$LOOKIN" -maxdepth 1 -name "$LOOKFOR*" |
		'ls' -d "$LOOKIN/$LOOKFOR"* |
		while read X; do
			if test -d "$X"; then
				echo "$X"
			fi
		done
	` 2> /dev/null
	# echo ">$NEWLIST<"

	if test "$NEWLIST" = ""; then
		# No directory found
		echo "X"`cursered;cursebold`" $LOOKIN/$LOOKFOR*"`cursenorm`
	elif test `echo "$NEWLIST" | countlines` = "1"; then
		# One unique dir =)
		echo ">"`cursegreen`" $NEWLIST"`cursenorm`
		'cd' "$NEWLIST"
	else
		# A few possibilities, suggest them to the user.
		# echo "? $NEWLIST" | tr "\n" " "
		echo "$NEWLIST" |
		sed "s+^\(.*$NEWDIR\)\(.*\)$+? "`cursegreen`"\1"`curseyellow`"\2"`cursenorm`"+"
		# sed 's+\(.*/\)\(.*\)+\? \1'`cursegreen`'\2/'`cursenorm`'+' |
		# sed 's+/+'`cursegreen`'/'`cursenorm`"+g"
		# echo -n "$NEWLIST" | tr "\n" " "
		# echo " ?"
	fi

fi > /dev/stderr

xttitle "$SHOWUSER$SHOWHOST$PWD %% "

# pwd >> $HOME/.dirhistory
