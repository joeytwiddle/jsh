#!/bin/sh
## jsh
## An alternative to using source startj to add J environment to your current
## shell, jsh will start a new shell with J environment.
## Neccessary to make a one-liner, because when sourcing with bash, the path
## of the script is unknown.
## Also makes it easy to leave the J environment again!
## Alternatively can be used as a one-liner to run a command inside J env, then exit.

## TODO: (document or fix) jsh is not like sh in that you cannot jsh <script> if <script> is not executable.  Also you cannot cat <script> | jsh, or can you?!  TEST!
## Aha, but you can: $JPATH/jsh sh <script> and presumably | to that too.

## TODO: calls to exit are fatal if user (daftly) sources: . .../jsh
##       so do not exit if $SHLVL == 1
##       or do not exit at all, just use a flag or structure to skip to the end

## OK I need to remove all the exits and use flow-control instead.
## I can either a) use a load of nested if's, or b) use a variable, eg. CONTINUE.

## Shit my collection of shellscripts (and the method of using them) really
## needs a proper name.  What about JSE (joey's shell environment)?  Nah that's naff!
## Or nash: not actually a shell
## exsh?  shext?  jshl?  nsh (neuralyte)?

## Fixed elsewhere (was todo):
## we ignores user's ~/.bashrc
## They might not want to run another shell!

# env > /tmp/env-$$

# set -x

# debug () {
	# test "$JSH_JSHDEBUG" && echo "$*" >&2
# }

if [ ! $COUNT_JSH_RUN ]
then COUNT_JSH_RUN=0
fi
COUNT_JSH_RUN=`expr "$COUNT_JSH_RUN" + 1`
export COUNT_JSH_RUN

case "$1" in
	-h|--help)
		"$0" jhelp
		exit 0
	;;
esac

if [ "$STARTJ_BLOCK" ]
then
	## Now part of normal operation for bash, so user can just set a call to jsh in their .bash_profile, but not have it infspawn!
	# echo "jsh: Aborting because STARTJ_BLOCK is set." >&2
	exit 0
fi

## Check that we have a valid JPATH environment variable:
if [ -z "$JPATH" ]
then
	## If not, we examine $0th arg and assume user called $JPATH/jsh
	if echo "$0" | grep "^/" > /dev/null
	then export JPATH="`dirname "$0"`"        ## absolute
	else export JPATH="$PWD/"`dirname "$0"`   ## relative
	fi
fi
if [ ! -d "$JPATH/tools" ]
then
	#echo "jsh: Could not find JPATH with subdir tools :-(" >&2
	#exit 1
	echo "Creating $JPATH/tools..."
	"$JPATH"/code/shellscript/init/refreshtoollinks
fi

if [ "$*" ]
then

	###=== Jsh has been asked to execute a command immediately, and return
	## We need only load a light (non-user) jsh environment, and execute the command

	## Non-interactive shell: start jenv then run command.
	. "$JPATH"/startj-simple
	## This "jsh -c <command>" option is useful for eg. pipes, especially when we can't "| jsh".
	if [ "$1" = -c ]
	then
		shift
		# verbosely eval "$@"
		exec $PRE eval "$@"
		# echo "$@" | sh ## yuk haven't tried it hope we don't need it!
	else
		# verbosely "$@"
		exec $PRE "$@"
	fi
	## alternatively: bash -c "$@"

else

	###=== Jsh has been called with no arguments
	## We will invoke a new shell (bash or zsh), and in it load the jsh environment, and jsh's friendly shell-user power-tweaks.

	## When we start the user shell, will we highlight standard-error for them in red?
	PRE=""
	## Oh dear: highlightstderr prevents su from working :S
	# if [ ! "$NO_TTY_CHECK_CONFIRMED" ] || tty -s
	# then
		# PRE="highlightstderr"
	# else
		# export NO_TTY_CHECK_CONFIRMED=true ## sub calls to jsh will not need to check
		# jshwarn "jsh started with no tty and no arguments :-o"
	# fi

	## TODO: DOC needed!
	## When we call bash or zsh, what gets passed down?
	## Obviously PATH, and exported variables.
	## But some stuff will not get passed down.
	## What about functions, aliases, ... ?
	## For that reason, we need to have the shell load startj in it's config.
	## It appears bash can do this with --rcfile, nice and neat.  :)
	## But if zsh does not have ~"source startj" in its .zshrc, some stuff will not get loaded.

	## Interactive shell: start user's favourite shell with startj as rc file.
	if [ -n "$JSH_START_FISH" ] && which fish >/dev/null 2>&1
	then
		## In earlier versions of fish, you cannot stty does not work from within fish.  Since I want Ctrl-S to be free to bind in Vim, we disable it before starting fish.
		stty -ixon
		exec $PRE fish
	## Second line is a check because: jsh in zsh will only work if startj is sourced in .zshrc
	elif which zsh >/dev/null 2>&1 &&
	   cat $HOME/.zshrc 2>/dev/null | grep -v "^[ 	]*#" | grep '^\(source\|\.\) .*/startj$' > /dev/null &&
	   [ ! "$USE_SHELL" = bash ] ## should come first, except when I'm testing the others ;)
	   # ( test $USER = joey || test $USER = pclark || test $USER = edwards )
	then
		## I believe zsh sources its own rc scripts automatically, so this is not needed:
		# export BASH_BASH=$HOME/.zshrc
		## However we are having trouble getting zsh to source the startj script!
		## These should work, but don't:
		# export ENV="$JPATH/startj"
		# env ENV="$JPATH/startj" zsh
		## Ah no, ENV is only for sh ksh compatibility.  We could start in one of those then change options to upgrade the sh!
		## So we actually end up sourcing startj in .zshrc :-(
		# zsh
		## Or use this (partially working) hack:
		# export BASH_ZSH=why_not
		# zsh $JPATH/startj
		## But it's no better than:
		# source $JPATH/startj # simple ## we want half-simple, exporting VARS, but skipping aliases which won't get exported
		[ "$JSHDEBUG" ] && echo "jsh: invoking zsh" >&2
		exec $PRE zsh
		## which isn't guaranteed to give aliases, but will work if .zshrc sources startj (for a second time!)
	else
		[ "$JSHDEBUG" ] && echo "jsh: invoking bash" >&2
		## Bash does not source its default .rcs when we specify startj, so startj should source them itself.
		## This is be triggered by:
		export BASH_BASH=yes_please
		exec $PRE bash --rcfile "$JPATH/startj"
		## This was failing on gentoo.
		# $PRE bash
	fi

fi

# RES="$?"
# ( tty >/dev/null && echo "[Leaving Jsh]" >&2 )
# exit "$RES"

