## jsh
## An alternative to using source startj to add J environment to your current
## shell, jsh will start a new shell with J environment.
## Neccessary to make a one-liner, because when sourcing with bash, the path
## of the script is unknown.
## Also makes it easy to leave the J environment again!
## Alternatively can be used as a one-liner to call run a command inside J env.

## Shit my collection of shellscripts (and the method of using them) really
## needs a proper name.  What about JSE (joey's shell environment)?  Nah that's naff!
## Or nash: not actually a shell
## exsh?  shext?  jshl?  nsh (neuralyte)?

## Fixed elsewhere (was todo):
## we ignores user's ~/.bashrc
## They might not want to run another shell!

## We assume user has called:
## $JPATH/jsh
## Since jsh is not sourced, "$0" should contain said call

if echo "$0" | grep "^/" > /dev/null; then
	export JPATH=`dirname "$0"`
else
	export JPATH="$PWD/"`dirname "$0"`
fi

if test ! "$*" = ""; then

	## Non-interactive shell: start jenv then run command.
	source "$JPATH"/startj-simple
	"$@"
	## alternatively: bash -c "$@"

else

	## Interactive shell: start user's favourite shell with startj as rc file.
	# if test `which zsh`; then
	## TODO: problems with zsh running startj on orion
	if test `hostname -s` = "hwi"; then
		export ENV="$JPATH/startj"
		zsh
	else
		## Bash will not import default .rcs as well startj, so startj has a digital hammer
		## triggered by:
		export BASH_BASH=$HOME/.bashrc
		bash --rcfile "$JPATH/startj"
	fi

fi
