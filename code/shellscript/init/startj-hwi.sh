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

SHOWHOST=$HOST
# Fix 'cos sometimes HOSTNAME is set instead of HOST
if test "$SHOWHOST" = ""; then
	export SHOWHOST=`echo "$HOSTNAME" | beforefirst "\."`
fi
SHOWHOST="$SHOWHOST:"
# Exception for user's "home machine"
if test "$SHOWHOST" = "hwi:"; then
	SHOWHOST=""
fi
SHOWUSER="$USER@"
if test "$SHOWUSER" = "joey@"; then
	SHOWUSER=""
fi

# tcsh makes itself known by ${shell} envvar.
# This says SHELL=bash on tao when zsh is run.  zsh only shows in ZSH_NAME !
# SHORTSHELL=`echo "$SHELL" | afterlast "/"`
SHELLPS="$$"
SHORTSHELL=`findjob "$SHELLPS" | grep 'sh$' | tail -1 | sed "s/.* \([^ ]*sh\)$/\1/"`
echo "shell = $SHORTSHELL"

# xterm title change
case $TERM in
	*term*)
		case $SHORTSHELL in
			zsh)
				swd () {
					# Dunno why doesn't work:
					# echo "$PWD" | sed "s|.+/\(.*/.*\)|\.\.\./\1|"
					# echo "$PWD" | sed "s|.*/.*/\(.*/.*\)|\.\.\./\1|"
					# echo "$PWD" | sed "s|.*/.*\(/.*/.*/.*\)|\.\.\.\1|"
					echo "$PWD" | sed "s|.*/.*/\(.*/.*/.*\)|_/\1|;s|^$HOME|~|"
				}
				preexec () {
					# $* repeats on magenta under zsh :-(
					export LASTCMD="$*"
					xttitle "# $LASTCMD [$SHOWUSER$SHOWHOST"`swd`"]"
				}
				precmd () {
					# xttitle "$SHOWHOST"`swd`" %% ($LASTCMD)"
					xttitle "$SHOWUSER$SHOWHOST"`swd`" %% ($LASTCMD)"
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
