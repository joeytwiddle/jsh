#!/bin/sh

export JPATH=$HOME/j
export PATH=$JPATH/tools:$PATH

source getmachineinfo

source joeysaliases
source cvsinit

if test $ZSH_NAME; then
	source zshkeys
fi

# source dirhistorysetup.bash
source dirhistorysetup.zsh
source hwipromptforbash
source hwipromptforzsh
source javainit
source hugsinit
source lscolsinit

alias hwicvs='cvs -d :pserver:joey@hwi.dyn.dhs.org:/stuff/cvsroot'
alias cvsimc='cvs -d :pserver:anonymous@cat.org.au:/usr/local/cvsroot'
alias cvsenhydra='cvs -d :pserver:anoncvs@enhydra.org:/u/cvs'

export FIGNORE=".class"

# Avoid error if not on a tty
if test ! "$BAUD" = "0"; then
	mesg y
fi

# Message on user login/out (zsh, tcsh, ...?)
export WATCH=all

if test "$HOST" = ""; then
	export HOST=`echo "$HOSTNAME" | beforefirst "\."`
	# echo "set HOST=\"$HOST\""
fi

SHORTSHELL=`echo "$SHELL" | afterlast "/"`
# echo "shell = $SHORTSHELL"

# tcsh makes itself known by ${shell} envvar.

# xterm title change
case $TERM in
	xterm*)
		case $SHORTSHELL in
			zsh)
				swd () {
					# Dunno why doesn't work:
					# echo "$PWD" | sed "s|.+/\(.*/.*\)|\.\.\./\1|"
					# echo "$PWD" | sed "s|.*/.*/\(.*/.*\)|\.\.\./\1|"
					# echo "$PWD" | sed "s|.*/.*\(/.*/.*/.*\)|\.\.\.\1|"
					echo "$PWD" | sed "s|.*/.*/\(.*/.*/.*\)|\1|"
				}
				preexec () {
					# $* repeats on magenta under zsh :-(
					export LASTCMD="$*"
					xttitle "$LASTCMD # [$HOST:"`swd`"]"
				}
				precmd () {
					xttitle "$HOST:"`swd`" %% ($LASTCMD)"
				}
			;;
			# Doesn't work 'cos tcsh can't exec this far!
			tcsh)
				alias postcmd 'xttitle "${USER}@${HOST}:${PWD}%% \!#"'
			;;
		esac
	;;
esac

# source $JPATH/tools/jshellalias
# source $JPATH/tools/jshellsetup
