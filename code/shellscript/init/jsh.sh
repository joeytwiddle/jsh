## jsh
## An alternative to using source startj to add J environment to your current
## shell, jsh will start a new shell with J environment.
## Neccessary to make a one-liner, because when sourcing with bash, the path
## of the script is unknown.
## Also makes it easy to leave the J environment again!
## Alternatively can be used as a one-liner to run a command inside J env, then exit.

## Shit my collection of shellscripts (and the method of using them) really
## needs a proper name.  What about JSE (joey's shell environment)?  Nah that's naff!
## Or nash: not actually a shell
## exsh?  shext?  jshl?  nsh (neuralyte)?

## Fixed elsewhere (was todo):
## we ignores user's ~/.bashrc
## They might not want to run another shell!

# set -x

# debug () {
	# test "$JSH_DEBUG" && echo "$*" >&2
# }

test "$STARTJ_BLOCK" && exit 0

## Check that we have a valid JPATH environment variable:
if test ! -d "$JPATH/tools"  ## the definitive proof no doubt!
then
	## If not, we examine $0th arg and assume user called $JPATH/jsh
	if echo "$0" | grep "^/" > /dev/null
	then export JPATH=`dirname "$0"`        ## absolute
	else export JPATH="$PWD/"`dirname "$0"` ## relative
	fi
	if test ! -d "$JPATH/tools"
	then
		echo "jsh: Could not find JPATH with subdir tools :-(" >&2
		exit 1
	fi
fi

if test "$*"; then

	## Non-interactive shell: start jenv then run command.
	source "$JPATH"/startj-simple
	"$@"
	## alternatively: bash -c "$@"

else

	## Interactive shell: start user's favourite shell with startj as rc file.
	# if test "`hostname`" = hwi && test $USER = joey; then
	# ( test -x /bin/zsh || test -x /usr/bin/zsh || test -x /usr/local/bin/zsh )
	if test `which zsh` &&
	   ( test $USER = joey || test $USER = pclark || test $USER = edwards )
	then
		## I believe zsh sources its own rc scripts automatically, so this is not needed:
		# export BASH_BASH=$HOME/.zshrc
		## However we are having trouble source the startj script!
		## These should work, but don't:
		# export ENV="$JPATH/startj"
		# env ENV="$JPATH/startj" zsh
		## So we actually end up sourcing startj in .zshrc :-(
		zsh
	else
		## Bash will not source its default .rcs when we specify startj, so startj has to source them itself.
		## triggered by:
		export BASH_BASH=yes_please
		# echo "calling bash --rcfile $JPATH/startj"
		bash --rcfile "$JPATH/startj"
	fi

fi
