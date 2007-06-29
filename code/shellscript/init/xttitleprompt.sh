## TODO: The default xttitle for a terminal window could be a sanitised version of the user's shell prompt (PS1/PROMPT) [remove colors+other escapes].  The current terminal is my own "traditional" shell prompt: the directory followed by a % (but for some reason I have them the other way around :P )

## Now does screen titles as well; should rename to generic_shell_update_titler_thingy

### xterm title change
# Requires SHORTSHELL from startj

XTTITLEPROMPT_SIMPLER=true

## Maybe too strict but this script is too heavy for low-spec machines.
if [ "$TERM" = xterm ] || [ "$TERM" = screen ]
then

	HEAD=""
	# if test "$TERM" = screen
	# then export HEAD="[screen] "
	# fi

	## If we are in a screen, but not on the local machine, we must have ssh'ed somewhere from within screen.
	SCRHEAD=""
	if [ "$TERM" = screen ] && [ ! "$STY" ]
	   # ! contains "$SCREENTITLE" "$SHOWHOST"
	then
		## If we want to display the machine name, and what it's up to, we should use screentitle -remote below.
		SCRHEAD="($SHORTHOST)"
		screentitle -remote "$SCRHEAD"
	fi

	## However, if we are in a local screen, ...

	[ "$USER" = joey ] && SHOWUSER= || SHOWUSER="$USER"
	[ "$HOST" = hwi ] && SHOWHOST= || SHOWHOST="@$SHORTHOST"
	# could try using `logname`

	export SHOWUSER # for d f b
	export SHOWHOST
	## Needed by others?

	# HEAD="$HEAD$SHOWHOST$SHOWUSER"
	HEAD="$HEAD$SHOWUSER$SHOWHOST"

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

	[ "$DEBUG" ] && debug "SHORTSHELL=$SHORTSHELL"

	case $SHORTSHELL in

		bash)
			if [ "$0" = "bash" ]
			then
				## For bash, get prompt to send xttitle escseq:
				# export TITLEBAR=`xttitle "\u@\h:\w"`
				## xterm title:
				# export TITLEBAR="\[\033]0;$HEAD\u@\h:\w\007\]"
				# jshinfo "Setting (bash) TITLEBAR=\"\[\033]0;$HEAD:\w\007\]\""
				export TITLEBAR="\[\033]0;$HEAD:\w\007\]"
				## removed \u and \h since they are in head already :P
				# export TITLEBAR="\[\033]0;% $HEAD:\w/\007\]"
				## do we really need to export it?
				# export TITLEBAR="% $HEAD:\w/"
				## screen title: "[" <directory> "]"
				# export TITLEBAR="$TITLEBAR\[k[\w]\\\\\]"
				# if [ "$STY" ]
				if [ "$TERM" = screen ]
				then
					jshinfo "Setting (bash,screen) TITLEBAR=\"$TITLEBAR\[k$SCRHEAD\w/\\\\\]\""
					export TITLEBAR="$TITLEBAR\[k$SCRHEAD\w/\\\\\]"
				fi
				# export TITLEBAR="$TITLEBAR`screentitle \"$SCRHEAD/\w/\"`" ## marche pas
				## but it might be better if it did, at least bash would pass back to remote screens
				## but also it wouldn't pass to local either!
				## although it would have a go right now!
				## xttitle does not seem to work as well as doing it directly here:
				# export XTTITLEBAR="\[\033]0;$TITLEBAR\007\]"
				# XTTITLEBAR="\[`xttitle "$TITLEBAR"`\]"
				# export XTTITLEBAR="\[\033]0;$XTTITLE_PRESTRING$TITLEBAR\007\]"
				# export PS1="$XTTITLEBAR$PS1"
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
				# echo "$PWD" | sed "s|.*/.*/\(.*/.*/.*\)|_/\1|;s|^$HOME|~|"
				echo "$PWD" | sed "s|.*/.*/\(.*/.*/.*\)|.../\1|;s|^$HOME|~|"
			}
			preexec () {
				## $* repeats under zsh4 :-(
				## $1 before alias expansion, $2 and $3 after
				export LASTCMD="$1"

				# xttitle "$HEAD# $LASTCMD [$SHOWUSER$SHOWHOST`swd`]"
				XTTITLE_DISPLAY="$HEAD# $LASTCMD"
				[ "$XTTITLEPROMPT_SIMPLER" ] || XTTITLE_DISPLAY="$XTTITLE_DISPLAY [$SHOWUSER$SHOWHOST`swd`]"
				xttitle "$XTTITLE_DISPLAY"

				# echo ">$STY<" >> /tmp/123
				# screentitle "$HEAD$SHOWUSER$SHOWHOST`swd` # $LASTCMD"
				# screentitle "[$HEAD#`echo \"$LASTCMD\" | cut -c -10`]"
				# screentitle "[$HEAD%`echo \"$LASTCMD\" | takecols 1 | cut -c -10`]"
				# [ "$SCREEN_TITLE_TMP" ] || SCREEN_TITLE_TMP="[$HEAD#`echo \"$LASTCMD\" | takecols 1 | cut -c -10`]"
				[ "$SCREENTITLE" ] &&
				SCREEN_TITLE_TMP="$SCREENTITLE" ||
				SCREEN_TITLE_TMP="#`echo \"$LASTCMD\" | takecols 1 | cut -c -10`"
				screentitle "$SCRHEAD$SCREEN_TITLE_TMP"
			}
			precmd () {
				# xttitle "$SHOWHOST"`swd`" % ($LASTCMD)"

				# xttitle "$HEAD$SHOWUSER$SHOWHOST`swd` % ($LASTCMD)"
				# XTTITLE_DISPLAY="% $HEAD$SHOWUSER$SHOWHOST`swd`"
				XTTITLE_DISPLAY="$HEAD:`swd` %"
				# XTTITLE_DISPLAY="$HEAD:`swd` % ($LASTCMD)"
				# XTTITLE_DISPLAY="$HEAD:`swd` % (`history | takecols 2 | tail -n 3 | tr '\n' ' '`)"
				# XTTITLE_DISPLAY="$HEAD:`swd` % ( `history | wc -l`: `history | takecols 2 | tail -n 3 | tr '\n' ' '`)"
				HISTNUM=`history | wc -l`
				[ "$HISTNUM" -gt 1 ] && HISTSHOW=" ( ... `history | takecols 2 | tail -n 3 | tr '\n' ' '`)" || HISTSHOW=
				XTTITLE_DISPLAY="$HEAD:`swd` %$HISTSHOW"
				[ "$XTTITLEPROMPT_SIMPLER" ] || XTTITLE_DISPLAY="$XTTITLE_DISPLAY ($LASTCMD)"
				xttitle "$XTTITLE_DISPLAY"

				# echo ">$STY<" >> /tmp/123
				# screentitle "[$HEAD$SHOWUSER$SHOWHOST%`swd | cut -c -10`]"
				# screentitle "[$HEAD$SHOWUSER$SHOWHOST%`swd | sed 's+.*/\(.*/.*\)+\1+' | cut -c -10`]"
				[ "$SCREENTITLE" ] &&
				SCREEN_TITLE_TMP="$SCREENTITLE" ||
				SCREEN_TITLE_TMP="`swd | sed 's+.*/\(.*/.*\)+\1+ ; s+.*\(..........\)+\1+'`/"
				screentitle "$SCRHEAD$SCREEN_TITLE_TMP"
			}
		;;

		## For tcsh, use postcmd builtin:
		## Doesn't actually appear 'cos tcsh can't exec this far!
		## See .tcshrc for actual postcmd!
		tcsh)
			alias postcmd 'xttitle "${HEAD}${USER}@${SHORTHOST}:${PWD}%% \!#"'
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
