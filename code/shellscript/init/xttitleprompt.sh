## Now does screen titles as well; should rename to generic_shell_update_titler_thingy

### xterm title change
# Requires SHORTSHELL from startj

## Maybe too strict but this script is too heavy for low-spec machines.
if test "$TERM" = xterm || [ "$TERM" = screen ]
then

	HEAD=""
	# if test "$TERM" = screen
	# then export HEAD="[screen] "
	# fi

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
	if test "$SHOWHOST" = "hwi:"
	then SHOWHOST=""
	fi
	if test "$SHOWUSER" = "joey@"
	then SHOWUSER=""
	fi
	export SHOWUSER # for d f b
	export SHOWHOST
	## Needed by others?

	# if xisrunning; then

		## Now below:
		# if test "$0" = "bash"; then
			# ## For bash, get prompt to send xttitle escseq:
			# # export TITLEBAR=`xttitle "\u@\h:\w"`
			# export TITLEBAR="\[\033]0;$HEAD\u@\h:\w\007\]"
			# export PS1="$TITLEBAR$PS1"
		# fi

		# case $TERM in
			# *term*)

	case $SHORTSHELL in

		bash)
			if test "$0" = "bash"; then
				## For bash, get prompt to send xttitle escseq:
				# export TITLEBAR=`xttitle "\u@\h:\w"`
				## xterm title:
				export TITLEBAR="\[\033]0;$HEAD\u@\h:\w\007\]"
				## screen title: "[" <directory> "]"
				export TITLEBAR="$TITLEBAR\[\033k[\w]\033\\\]"
				export PS1="$TITLEBAR$PS1"
			fi
		;;

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
				xttitle "$HEAD# $LASTCMD [$SHOWUSER$SHOWHOST`swd`]"
				echo ">$STY<" >> /tmp/123
				# screentitle "$HEAD$SHOWUSER$SHOWHOST`swd` # $LASTCMD"
				# screentitle "[$HEAD#`echo \"$LASTCMD\" | cut -c -10`]"
				# screentitle "[$HEAD%`echo \"$LASTCMD\" | takecols 1 | cut -c -10`]"
				# [ "$SCREEN_TITLE_TMP" ] || SCREEN_TITLE_TMP="[$HEAD#`echo \"$LASTCMD\" | takecols 1 | cut -c -10`]"
				[ "$SCREENTITLE" ] &&
				SCREEN_TITLE_TMP="$SCREENTITLE" ||
				SCREEN_TITLE_TMP="#`echo \"$LASTCMD\" | takecols 1 | cut -c -10`"
				screentitle "$SCREEN_TITLE_TMP"
			}
			precmd () {
				# xttitle "$SHOWHOST"`swd`" % ($LASTCMD)"
				xttitle "$HEAD$SHOWUSER$SHOWHOST`swd` % ($LASTCMD)"
				echo ">$STY<" >> /tmp/123
				# screentitle "[$HEAD$SHOWUSER$SHOWHOST%`swd | cut -c -10`]"
				# screentitle "[$HEAD$SHOWUSER$SHOWHOST%`swd | sed 's+.*/\(.*/.*\)+\1+' | cut -c -10`]"
				[ "$SCREENTITLE" ] &&
				SCREEN_TITLE_TMP="$SCREENTITLE" ||
				SCREEN_TITLE_TMP="$HEAD$SHOWUSER$SHOWHOST`swd | sed 's+.*/\(.*/.*\)+\1+ ; s+.*\(..........\)+\1+'`/"
				screentitle "$SCREEN_TITLE_TMP"
			}
		;;

		## For tcsh, use postcmd builtin:
		## Doesn't actually appear 'cos tcsh can't exec this far!
		## See .tcshrc for actual postcmd!
		tcsh)
			alias postcmd 'xttitle "${HEAD}${USER}@${HOST}:${PWD}%% \!#"'
		;;

		bash)
			noop ## should be already done above
		;;

		*)
			echo "xttitleprompt: do not recognise sh=$SHORTSHELL" >&2
		;;

	esac

			# ;;
		# esac

	# fi

	cd . ## to do the initial titling

fi
