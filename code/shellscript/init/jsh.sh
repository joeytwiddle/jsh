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
## exsh?  shext?  jshl?

## TODO:
## we ignores user's ~/.bashrc
## They might not want to run another shell!

## We assume user has called:
## $JPATH/jsh
## Since jsh is not sourced, "$0" should contain said call

export JPATH=`dirname "$0"`

if test ! "$*" = ""; then

	## Non-interactive shell: start jenv then run command.
	source "$JPATH"/startj-simple
	"$@"

else

	## Interactive shell: start user's favourite sh with startj as rc file.
	bash --rcfile $JPATH/startj

fi
