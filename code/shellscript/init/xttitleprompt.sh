### xterm title change
# Requires SHORTSHELL from startj

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
						# xttitle "$SHOWHOST"`swd`" % ($LASTCMD)"
						xttitle "$SHOWUSER$SHOWHOST"`swd`" % ($LASTCMD)"
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
fi

cd . ## to do the initial titling
