## jsh
## An alternative to using source startj to add J environment to your current
## shell, jsh will start a new shell with J environment.
## Neccessary to make a one-liner, because when sourcing with bash, the path
## of the script is unknown.
## Also makes it easy to leave the J environment again!
## Alternatively can be used as a one-liner to run a command inside J env, then exit.

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
	# test "$JSH_DEBUG" && echo "$*" >&2
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
if [ ! -d "$JPATH/tools" ]  ## the definitive proof no doubt!
then
	## If not, we examine $0th arg and assume user called $JPATH/jsh
	if echo "$0" | grep "^/" > /dev/null
	then export JPATH=`dirname "$0"`        ## absolute
	else export JPATH="$PWD/"`dirname "$0"` ## relative
	fi
	if [ ! -d "$JPATH/tools" ]
	then
		echo "jsh: Could not find JPATH with subdir tools :-(" >&2
		exit 1
	fi
fi

if [ "$*" ]
then

	## Non-interactive shell: start jenv then run command.
	source "$JPATH"/startj-simple
	"$@"
	## alternatively: bash -c "$@"

else

	## Interactive shell: start user's favourite shell with startj as rc file.
	# if test "`hostname`" = hwi && test $USER = joey; then
	# ( test -x /bin/zsh || test -x /usr/bin/zsh || test -x /usr/local/bin/zsh )
	if [ `which zsh` > /dev/null 2>&1 ] &&
	   grep '^\(source\|\.\) .*/startj$' $HOME/.zshrc > /dev/null 2>&1
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
		[ "$DEBUG" ] && echo "jsh: invoking zsh" >&2
		zsh
		## which isn't guaranteed to give aliases, but will work if .zshrc sources startj (for a second time!)
	else
		## Bash will not source its default .rcs when we specify startj, so startj has to source them itself.
		## triggered by:
		export BASH_BASH=yes_please
		# echo "calling bash --rcfile $JPATH/startj"
		[ "$DEBUG" ] && echo "jsh: invoking bash" >&2
		bash --rcfile "$JPATH/startj"
	fi

fi
