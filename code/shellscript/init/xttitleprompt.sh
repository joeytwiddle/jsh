### xterm title change
# Requires SHORTSHELL from startj

## The screen check, and hence HEAD at the moment may be redundant
## because screen probably disables X forwarding.
HEAD=""
if test "$TERM" = screen
then export HEAD="[screen] "
fi

## Gather hostname and username
SHOWHOST=$HOST
## Fix 'cos sometimes HOSTNAME is set instead of HOST
if test "$SHOWHOST" = ""; then
	export SHOWHOST=`echo "$HOSTNAME" | beforefirst "\."`
fi
SHOWHOST="$SHOWHOST:"
SHOWUSER="$USER@"
# could try using `logname`

## Exception: trim for user's "home machine"
if test "$SHOWHOST" = "hwi:"; then
	SHOWHOST=""
fi
if test "$SHOWUSER" = "joey@"; then
	SHOWUSER=""
fi
export SHOWUSER # for d f b
export SHOWHOST

if xisrunning; then
	if test "$0" = "bash"; then
		## For bash, get prompt to send xttitle escseq:
		# export TITLEBAR=`xttitle "\u@\h:\w"`
		export TITLEBAR="\[\033]0;$HEAD\u@\h:\w\007\]"
		export PS1="$TITLEBAR$PS1"
	fi
	case $TERM in
		*term*)
			case $SHORTSHELL in

				zsh)
					## These two should go outside TERM case but only zsh!
					export HISTSIZE=10000
					export EXTENDED_HISTORY=true
					## For zsh we define the preexec/cmd builtins
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
						xttitle "$HEAD# $LASTCMD [$SHOWUSER$SHOWHOST"`swd`"]"
					}
					precmd () {
						# xttitle "$SHOWHOST"`swd`" % ($LASTCMD)"
						xttitle "$HEAD$SHOWUSER$SHOWHOST"`swd`" % ($LASTCMD)"
					}
				;;

				## For tcsh, use postcmd builtin:
				## Doesn't actually appear 'cos tcsh can't exec this far!
				## See .tcshrc for actual postcmd!
				tcsh)
					alias postcmd 'xttitle "${HEAD}${USER}@${HOST}:${PWD}%% \!#"'
				;;

			esac
		;;
	esac
fi

cd . ## to do the initial titling
