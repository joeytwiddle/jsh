export JPATH=$HOME/j
export PATH=$JPATH/tools:$PATH

# Setup user bin, libs, man etc...
export PATH=$HOME/bin:$PATH
# not yet finished - refer too setuppath in pclark/pubbin

if test ! "$1" = "simple"; then

. getmachineinfo

. joeysaliases
. cvsinit

if test $ZSH_NAME; then
	. zshkeys
fi

# . dirhistorysetup.bash
. dirhistorysetup.zsh
. hwipromptforbash
. hwipromptforzsh
. javainit
. hugsinit
. lscolsinit

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

# What shell are we running?
# This says SHELL=bash on tao when zsh is run.  zsh only shows in ZSH_NAME !
SHELLPS="$$"
SHORTSHELL=`findjob "$SHELLPS" | grep 'sh$' | tail -1 | sed "s/.* \([^ ]*sh\)$/\1/"`
# echo "shell = $SHORTSHELL"
# tcsh makes itself known by ${shell} envvar.
# This says SHELL=bash on tao when zsh is run.  zsh only shows in ZSH_NAME !
# SHORTSHELL=`echo "$SHELL" | afterlast "/"`

# Gather hostname and username
SHOWHOST=$HOST
# Fix 'cos sometimes HOSTNAME is set instead of HOST
if test "$SHOWHOST" = ""; then
	export SHOWHOST=`echo "$HOSTNAME" | beforefirst "\."`
fi
SHOWHOST="$SHOWHOST:"
SHOWUSER="$USER@"

# Exception: trim for user's "home machine"
if test "$SHOWHOST" = "hwi:"; then
	SHOWHOST=""
fi
if test "$SHOWUSER" = "joey@"; then
	SHOWUSER=""
fi
export SHOWHOST # for d f b

# tcsh makes itself known by ${shell} envvar.

# xterm title change
case $TERM in
	*term*)
		case $SHORTSHELL in

			bash)
				# For bash, get prompt to send xttitle escseq:
				# export TITLEBAR=`xttitle "\u@\h:\w"`
				export TITLEBAR="\[\033]0;\u@\h:\w\007\]"
				export PS1="$TITLEBAR$PS1"
			;;

			zsh)
				# For zsh, use preexec/cmd builtins
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

			# For tcsh, use postcmd builtin:
			# Doesn't actually appear 'cos tcsh can't exec this far!
			# See .tcshrc for actual postcmd!
			tcsh)
				alias postcmd 'xttitle "${USER}@${HOST}:${PWD}%% \!#"'
			;;

		esac
	;;
esac

# . $JPATH/tools/jshellalias
# . $JPATH/tools/jshellsetup

fi
