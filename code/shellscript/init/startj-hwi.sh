#!/bin/sh

export JPATH=$HOME/j
export PATH=$JPATH/tools:$PATH

# Don't know why Debian lost this pathdir:
export PATH=$PATH:/usr/X11R6/bin/

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

export WATCH=all

SHORTSHELL=`echo "$SHELL" | afterlast "/"`

echo "shell = $SHORTSHELL"

# xterm title change
case $TERM in
	xterm*)
		case $SHORTSHELL in
			zsh)
				preexec () {
					xttitle "$USER@$HOST:$PWD% $*"
					# print -Pn "\e]0;$*\a"
				}
			;;
			# Doesn't work 'cos tcsh can't exec my scripts!
			tcsh)
				alias postcmd 'xttitle "${USER}@${HOST}:${PWD}% \!#"'
			;;
		esac
	;;
esac

# source $JPATH/tools/jshellalias
# source $JPATH/tools/jshellsetup
