#!/bin/bash
# Todo: Make it work on multiple files
# er does work on multiple files but must be in quotes - fix?

## This is OK on Linux but not Unix (Why? ...)
# littletest() {
#   newer "$file" "$COMPFILE"
# }

# Not sure what ignore does.
# Difference appears to be all files in dir
# as opposed to files provided in list

# Halves the forking
. importshfn newer

if [ "$1" = "--help" ] || [ "$1" = "" ] || [ "$2" = "" ]
then
cat << !

onchange [-fg] [-d] [ -ignore | <paths>... ] [do] <command>

  You may use a glob in <paths> but it should be contained in quotes if you
  want it to be evaluated later (after the call to onchange).

  -ignore means you need not provide a file list, the current folder will be
          scanned.

  -d is "desensitize" - we will not re-trigger on any files changed during the
     build process (command).

     You will probably want -d if your <command> outputs files in the same path
     that you are checking.

     You will probably want -d if you are using -ignore.  (That used to be
     default behaviour ... we may want to restore that ...)

  -fg runs in the current shell instead of popping up a new terminal.  It is
      also used internally.

  The do keyword is needed if you want <command> to be more than one argument.

  There is currently no support for the command to know which file changed, but
  there could be...

  Checking is done once per second - I don't want to hang around waiting for a
  build to start!  Ideally we would make it even driven!

!
# NO!    If you are really cunning, you could use "\$file" in your command!
exit 1
fi

if [ "$1" = "-fg" ]
then shift
else
	## I removed
	# nice -n 2 
	## from the two commands below, because although we might want watching to
	## be low-priority, I often want compiling to go faster than the currently
	## running program!  So unless we can renice the action (compilation) back
	## to 0, I don't want to nice the whole thing.
	if xisrunning
	then xterm -e nice -n 2 onchange -fg "$@" &
	else nice -n 2 onchange -fg "$@" &
	fi
	exit
fi

if [ "$1" = "-d" ]
then
	DESENSITIZE=true
	shift
fi

if [ "$1" = "-ignore" ]
then
	shift
	paths_to_check=.
else
	paths_to_check=
	while [ ! "$1" = "do" ] && [ ! "$2" = "" ]
	do
		paths_to_check="$paths_to_check $1"
		shift
	done
fi
[ "$1" = "do" ] && shift

COMMANDONCHANGE="eval $*"

[ "$COLUMNS" = "" ] && export COLUMNS=80
run_command() {
	touch "$COMPFILE"
	cursecyan
	for X in `seq 1 $COLUMNS`; do printf "-"; done; echo
	echo "Files changed: $whatChanged"
	echo "Running: $COMMANDONCHANGE"
	cursenorm
	xttitle ">> onchange running $COMMANDONCHANGE ($whatChanged changed)"
	highlightstderr $COMMANDONCHANGE
	exitCode="$?"
	cursecyan
	if [ "$exitCode" = 0 ]
	then echo "Done."
	else echo "`cursered;cursebold`[onchange] Command failed with exit code $exitCode:`cursenorm` $COMMANDONCHANGE"
	fi
	cursenorm
	echo
	[ "$DESENSITIZE" ] && sleep 1 && touch "$COMPFILE"
	xttitle "## onchange watching $paths_to_check ($whatChanged changed last)"
}

xttitle "## onchange watching $paths_to_check"
COMPFILE=`jgettmp onchange`
# COMPFILE="$JPATH/tmp/onchange.tmp"

touch "$COMPFILE"
while true
do
	sleep 1
	# breakonctrlc
	newer_files=`
		find $paths_to_check -type f -newer "$COMPFILE" |
		grep -v '/\.'   # Ignore dot folders and dot files (e.g. Vim swapfiles)
	`
	if [ -n "$newer_files" ]
	then
		whatChanged="$(echo "$newer_files" | tr '\n' ' ' | sed 's+ $++')"
		run_command
		# Do not desensitize by default.
		# The disadvantage of desensitizing is that a slow build process might not notice if a source files was changed during the build.  This might leave the developer confused: he should righly expect a fresh build to run for each file saved, regardless of the build duration.
		#sleep 1
		#touch "$COMPFILE"
	fi
done

jdeltmp "$COMPFILE"
