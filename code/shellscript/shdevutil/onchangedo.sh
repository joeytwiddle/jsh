#!/usr/bin/env bash

# TODO: We should really separate files and command with -- but this would be a breaking change

if [ "$*" = "" ] || [ "$1" = --help ]
then
	cat << !!!

onchangedo <path_to_executable>              (watches the executable for changes)

onchangedo <command_which_is_not_a_file>     (watches current folder)

onchangedo <command_with_arguments>          (watches both)

When a change is detected it will run the given command.

It's useful for automated builds/tasks.

!!!
	exit 1
fi

# Run it once at the start.  (That's often desirable, but we could deprecate it.)
verbosely eval "$@"

timerfile="/tmp/onchangedo.$USER.$$"
touch "$timerfile"

while true
do

	# FILES=`echolines "$@" | filesonly`
	FILES=`echolines $* | filter_list_with test -e`

	[ "$FILES" ] || FILES=". -maxdepth 1"

	# if find "$@" -newer "$timerfile"
	if find $FILES -newer "$timerfile" | higrep . | grep .
	then
		# This used to be below, but it's better up here
		touch "$timerfile"
		verbosely eval "$@"
	else
		# verbosely sleep 10
		sleep 3
	fi

done
