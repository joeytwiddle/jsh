## Try to guess the top directory of j install
## If all below fails, then you should set it youself with export JPATH=...; source $JPATH/startj
if test ! $JPATH; then
	if test -d "$HOME/j"; then
		export JPATH=$HOME/j
	## This doesn't work: bash cannot see it unless we call startj direct (no source)
	elif test -d `dirname "$0"`; then
		export JPATH=`dirname "$0"`
		echo "startj: guessed JPATH=$JPATH"
	else
		echo "startj: Could not find JPATH. Not starting."
		# env > /tmp/env.out
		exit 0
	fi
fi
export PATH=$JPATH/tools:$PATH

## Setup user bin, libs, man etc...
export PATH=$HOME/bin:$PATH
## not yet finished, should be option - refer to setuppath in pclark/pubbin

# zsh on Solaris gives errors on . so I use source

source javainit
source hugsinit

### NB: On Hwi with /bin/sh ". startj simple" does not provide "simple" in $1 !

if test ! "$1" = "simple"; then

	source getmachineinfo

	source joeysaliases
	source cvsinit

	# source dirhistorysetup.bash
	source dirhistorysetup.zsh
	source hwipromptforbash
	source hwipromptforzsh
	source lscolsinit

	alias cvshwi='cvs -z6 -d :pserver:joey@hwi.ath.cx:/stuff/cvsroot'
	alias cvsimc='cvs -d :pserver:anonymous@cat.org.au:/usr/local/cvsroot'
	alias cvsenhydra='cvs -d :pserver:anoncvs@enhydra.org:/u/cvs'

	export FIGNORE=".class"

	## Avoid error if not on a tty
	## Nice try Joey but doesn't work on kimo.
	# if test ! "$BAUD" = "0"; then
		mesg y
	# fi

	## Message on user login/out (zsh, tcsh, ...?)
	export WATCH=all

	## What shell are we running?
	## This says SHELL=bash on tao when zsh is run.  zsh only shows in ZSH_NAME !
	## $0 does OK for bash (at least when in .bash_profile!)
	SHELLPS="$$"
	SHORTSHELL=`
		findjob "$SHELLPS" |
		grep 'sh$' |
		tail -1 |
		sed "s/.* \([^ ]*sh\)$/\1/" |
		sed "s/^-//"
	`
	# echo "shell = $SHORTSHELL"
	## tcsh makes itself known by ${shell} envvar.
	## This says SHELL=bash on tao when zsh is run.  zsh only shows in ZSH_NAME !
	# SHORTSHELL=`echo "$SHELL" | afterlast "/"`

	## for bash, base="bash"
	## for zsh, base="startj" !
	# base=${0##*/}
	# echo "base = >$base<"

	if test $ZSH_NAME; then
		source zshkeys
	fi
	if test "$SHORTSHELL" = "bash"; then
		source bashkeys
	fi

	### xterm title change

	## Gather hostname and username
	SHOWHOST=$HOST
	## Fix 'cos sometimes HOSTNAME is set instead of HOST
	if test "$SHOWHOST" = ""; then
		export SHOWHOST=`echo "$HOSTNAME" | beforefirst "\."`
	fi
	SHOWHOST="$SHOWHOST:"
	SHOWUSER="$USER@"

	## Exception: trim for user's "home machine"
	if test "$SHOWHOST" = "hwi:"; then
		SHOWHOST=""
	fi
	if test "$SHOWUSER" = "joey@"; then
		SHOWUSER=""
	fi
	export SHOWUSER # for d f b
	export SHOWHOST

	if test "$0" = "bash"; then
		## For bash, get prompt to send xttitle escseq:
		# export TITLEBAR=`xttitle "\u@\h:\w"`
		export TITLEBAR="\[\033]0;\u@\h:\w\007\]"
		export PS1="$TITLEBAR$PS1"
	fi
	case $TERM in
		*term*)
			case $SHORTSHELL in

				zsh)
					## These two should go outside TERM case but only zsh!
					export HISTSIZE=10000
					export EXTENDED_HISTORY=true
					## For zsh, use preexec/cmd builtins
					swd () {
						## Dunno why doesn't work:
						# echo "$PWD" | sed "s|.+/\(.*/.*\)|\.\.\./\1|"
						# echo "$PWD" | sed "s|.*/.*/\(.*/.*\)|\.\.\./\1|"
						# echo "$PWD" | sed "s|.*/.*\(/.*/.*/.*\)|\.\.\.\1|"
						echo "$PWD" | sed "s|.*/.*/\(.*/.*/.*\)|_/\1|;s|^$HOME|~|"
					}
					preexec () {
						## $* repeats under zsh4 :-(
						## $1 before alias expansion, $2 and $3 after
						export LASTCMD="$1"
						xttitle "# $LASTCMD [$SHOWUSER$SHOWHOST"`swd`"]"
					}
					precmd () {
						# xttitle "$SHOWHOST"`swd`" %% ($LASTCMD)"
						xttitle "$SHOWUSER$SHOWHOST"`swd`" %% ($LASTCMD)"
					}
				;;

				## For tcsh, use postcmd builtin:
				## Doesn't actually appear 'cos tcsh can't exec this far!
				## See .tcshrc for actual postcmd!
				tcsh)
					alias postcmd 'xttitle "${USER}@${HOST}:${PWD}%% \!#"'
				;;

			esac
		;;
	esac

	cd . ## to do the initial titling
	## TODO: do this some other way: if sourced we might not want to change dir. Oh we don't change!

fi
