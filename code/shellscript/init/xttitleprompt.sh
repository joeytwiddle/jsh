## Initialises your shell to update the window title of your terminal application with information about the shell
## @sourceme
## This script must be sourced!  E.g.: . xttitleprompt

## TODO: The default xttitle for a terminal window could be a sanitised version of the user's shell prompt (PS1/PROMPT) [remove colors+other escapes].  The current terminal is my own "traditional" shell prompt: the directory followed by a % (but for some reason I have them the other way around :P )
## <greycat> hmm, my title() function uses echo -en "\e]2;$1\a"

## Now does screen titles as well; should rename to generic_shell_update_titler_thingy

### xterm title change
# Requires SHORTSHELL from startj

# XTTITLEPROMPT_SIMPLER=true
XTTITLEPROMPT_SHOW_JOBS=1

## Maybe too strict but this script is too heavy for low-spec machines and
## terms, so we whitelist modern stuff with known xttitle support, and drop
## people's ssh streams or legacy connections.  If they have vt100 we assume no
## xttitle support?
if [ "$TERM" = xterm ] || [ "$TERM" = "xterm-256color" ] || [ "$TERM" = Eterm ] || [ "$TERM" = screen ] || [ "$TERM" = "screen-256color" ]
then

	# XTTITLE_HEAD=""
	# if test "$TERM" = screen
	# then export XTTITLE_HEAD="[screen] "
	# fi

	## If we are in a screen, but not on the local machine, we must have ssh'ed somewhere from within screen.
	## We also want to do this for tmux.  We can check for $STY or $TMUX.
	SCRHEAD=""
	if { [ "$TERM" = screen ] || [ "$TERM" = "screen-256color" ]; } && [ ! "$STY" ]
	   # ! contains "$SCREENTITLE" "$SHOWHOST"
	then
		## In tmux, displaying the hostname for every window wastes a lot of space.  Let's not do that!
		## But we will do it if this is an sshd login; they are probably running screen or tmux on the client.
		if [ -n "$SSH_CLIENT" ] || [ -z "$TMUX" ]
		then
			## If we want to display the machine name, and what it's up to, we should use screentitle -remote below.
			SCRHEAD="($SHORTHOST)"
			screentitle -remote "$SCRHEAD"
		fi
	fi

	# [ "$USER" = foo ] && SHOWUSER= || SHOWUSER="$USER"
	# [ "$HOST" = bar ] && SHOWHOST= || SHOWHOST="@$SHORTHOST"
	# export SHOWUSER
	# export SHOWHOST
	# XTTITLE_HEAD="$XTTITLE_HEAD$SHOWUSER$SHOWHOST"

	# export XTTITLE_HEAD="<xterm> $XTTITLE_HEAD"

	## We don't use SHOWUSER or SHOWHOST or SHOWUSERHOST any more.
	## We use the more general purpose XTTITLE_HEAD.
	if [ -n "$SSH_CLIENT" ]
	then XTTITLE_HEAD="${XTTITLE_HEAD}${USER}@${SHORTHOST}"
	fi

	# if xisrunning; then

		## Now below:
		# if test "$0" = "bash"; then
			# ## For bash, get prompt to send xttitle escseq:
			# # export TITLEBAR=`xttitle "\u@\h:\w"`
			# export TITLEBAR="\[\033]0;$XTTITLE_HEAD\u@\h:\w\007\]"
			# export PS1="$TITLEBAR$PS1"
		# fi

		# case $TERM in
			# *term*)

	[ "$DEBUG" ] && debug "SHORTSHELL=$SHORTSHELL"

	case $SHORTSHELL in

		bash)
			## NOTE: We are currently not using this.  See hwipromptforbash's XTTSTR
			## TODO: bash now has PROMPT_COMMAND - we could use that to set a more advanced title
			# if [ "$0" = "bash" ]
			# then
				## For bash, get prompt to send xttitle escseq:
				# export TITLEBAR=`xttitle "\u@\h:\w"`
				## xterm title:
				# export TITLEBAR="\[\033]0;$XTTITLE_HEAD\u@\h:\w\007\]"
				# jshinfo "Setting (bash) TITLEBAR=\"\[\033]0;$XTTITLE_HEAD:\w\007\]\""
				# export TITLEBAR="\[\033]0;$XTTITLE_HEAD\w\007\]"
				## removed \u and \h since they are in head already :P
				# export TITLEBAR="\[\033]0;% $XTTITLE_HEAD:\w/\007\]"
				## do we really need to export it?
				# export TITLEBAR="% $XTTITLE_HEAD:\w/"
				## screen title: "[" <directory> "]"
				# export TITLEBAR="$TITLEBAR\[k[\w]\\\\\]"
				# if [ "$STY" ]

				# export TITLEBAR="$TITLEBAR`screentitle \"$SCRHEAD/\w/\"`" ## marche pas
				## but it might be better if it did, at least bash would pass back to remote screens
				## but also it wouldn't pass to local either!
				## although it would have a go right now!
				## xttitle does not seem to work as well as doing it directly here:
				# export XTTITLEBAR="\[\033]0;$TITLEBAR\007\]"
				# XTTITLEBAR="\[`xttitle "$TITLEBAR"`\]"
				# export XTTITLEBAR="\[\033]0;$XTTITLE_PRESTRING$TITLEBAR\007\]"
				# export PS1="$XTTITLEBAR$PS1"
				#export PS1="$TITLEBAR$PS1"

				# PS1="\\[`xttitle "\u@\h:\W\$ (\#)"`\\]""$PS1"
				# PS1="\\[`xttitle "(\#) \u@\h:\w\$ [\A] \j"`\\]""$PS1"
				# PS1="\\[`xttitle "(\#) \u@\h:\w\$   [\A]"`\\]""$PS1"

				## Time: [\A]
				#DISPLAY_STR="% ${XTTITLE_HEAD}\w/ _ (\#) [\A]"
				## Simplify: Remove _, history length, and time
				#DISPLAY_STR="% ${XTTITLE_HEAD}\w/"
				DISPLAY_STR="${XTTITLE_HEAD}\w/ _"
				## On macOS iTerm2 I prefer a short string (just the folder name) to fit into the small tabs
				## Same for screen and tmux
				if [ "$(uname)" = Darwin ] || [ "$TERM" = screen ] || [ -n "$TMUX" ]
				then DISPLAY_STR="${XTTITLE_HEAD}\W/"
				fi
				if [ "$TERM" = screen ]
				then
					# jshinfo "Setting (bash,screen) TITLEBAR=\"$TITLEBAR\[k$SCRHEAD\w/\\\\\]\""
					#DISPLAY_STR="${DISPLAY_STR}\[k${SCRHEAD}\w/\\\\\]"
					# The above might have been causing mis-alignment on my DO server
					# https://stackoverflow.com/questions/40234553/how-to-rename-a-pane-in-tmux
					# StackOverflow recommends this:
					#     \033]2;${SCRHEAD}\033\\
					:
				fi

				## This doesn't work
				# XTTSTR="$(xttitle "$DISPLAY_STR")"
				XTTSTR="\033]0;${DISPLAY_STR}\007"
				## This might work better on Cygwin
				# XTTSTR="$(printf "]0;%s" "$DISPLAY_STR")"

				PS1="$PS1\[$XTTSTR\]"
			# fi
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

				## Nice, gives self and up to 2 parent folders:
				# echo "$PWD" | sed "s|.*/.*/\(.*/.*/.*\)|.../\1|;s|^$HOME|~|"

				if [ "$PWD" = "$HOME" ]
				then echo "~"
				else
					## Just current folder name:
					echo "$PWD" | sed 's+.*/++'
				fi
			}
			preexec () {
				## $* repeats under zsh4 :-(
				## $1 before alias expansion, $2 and $3 after
				export LASTCMD="$1"

				if [ ! "$SUPPRESS_PREEXEC" ]
				then
					# xttitle "$XTTITLE_HEAD# $LASTCMD [$SHOWUSER$SHOWHOST`swd`]"
					# [ "$XTTITLEPROMPT_SIMPLER" ] || XTTITLE_DISPLAY="$XTTITLE_DISPLAY [$SHOWUSER$SHOWHOST`swd`]"

					HISTNUM="$((HISTCMD))"
					if [ "$SAVEHIST" ] && [ ! "$HISTNUM" -lt "$SAVEHIST" ]
					then HISTNUM=$((HISTNUM-SAVEHIST))
					fi

					#xttitle "$XTTITLE_HEAD# `swd`/ $LASTCMD   ($HISTNUM)"
					## Simplify
					xttitle "$XTTITLE_HEAD`swd`/ $LASTCMD"

					# echo ">$STY<" >> /tmp/123
					# screentitle "$XTTITLE_HEAD$SHOWUSER$SHOWHOST`swd` # $LASTCMD"
					# screentitle "[$XTTITLE_HEAD#`echo \"$LASTCMD\" | cut -c -10`]"
					# screentitle "[$XTTITLE_HEAD%`echo \"$LASTCMD\" | takecols 1 | cut -c -10`]"
					# [ "$SCREEN_TITLE_TMP" ] || SCREEN_TITLE_TMP="[$XTTITLE_HEAD#`echo \"$LASTCMD\" | takecols 1 | cut -c -10`]"
					[ "$SCREENTITLE" ] &&
					SCREEN_TITLE_TMP="$SCREENTITLE" ||
					SCREEN_TITLE_TMP="#`echo \"$LASTCMD\" | takecols 1 | cut -c -10`"
					screentitle "$SCRHEAD$SCREEN_TITLE_TMP"
				fi
			}
			precmd () {
				if [ ! "$SUPPRESS_PRECMD" ]
				then
					# xttitle "$SHOWHOST"`swd`" % ($LASTCMD)"

					# xttitle "$XTTITLE_HEAD$SHOWUSER$SHOWHOST`swd` % ($LASTCMD)"
					# XTTITLE_DISPLAY="% $XTTITLE_HEAD$SHOWUSER$SHOWHOST`swd`"
					# XTTITLE_DISPLAY="$XTTITLE_HEAD:`swd`%"
					# XTTITLE_DISPLAY="$XTTITLE_HEAD:`swd` % ($LASTCMD)"
					# XTTITLE_DISPLAY="$XTTITLE_HEAD:`swd` % (`history | takecols 2 | tail -n 3 | tr '\n' ' '`)"
					# XTTITLE_DISPLAY="$XTTITLE_HEAD:`swd` % ( `history | wc -l`: `history | takecols 2 | tail -n 3 | tr '\n' ' '`)"
					## This is madness it should be an add-on not part of or even an option to the default jsh :P (?)
					# HISTNUM=`history 0 | wc -l`
					HISTNUM="$((HISTCMD-1))"
					## Unfortunately HISTNUM starts reporting at 1000 if SAVEHIST=1000, but I want to start reporting from 0!
					## LINENO works in the shell but not in a script file
					if [ "$SAVEHIST" ] && [ ! "$HISTNUM" -lt "$SAVEHIST" ]
					then HISTNUM=$((HISTNUM-SAVEHIST))
					fi
					# [ "$HISTNUM" -gt 1 ] && HISTSHOW=" ( ... `history | takecols 2 | tail -n 3 | tr '\n' ' '`)" || HISTSHOW=
					# [ "$HISTNUM" -gt 9 ] && HISTNUM="$HISTNUM:" || HISTNUM=
					# HISTSHOW=" ( $HISTNUM ... `history | takecols 2 | tail -n 3 | tr '\n' ' '`)" || HISTSHOW=
					# HISTSHOW="<$HISTNUM...`history | tail -n 20 | takecols 2 | removeduplicatelinespo | tail -n 3 | tr '\n' ',' | sed 's+.$++'`>" || HISTSHOW=
					## DONE: we actually want removeduplicatelinespo-reversed (reversed before input, and after output)
					## ? should be exit code of last command
					# [ "$HISTNUM" -gt 10 ] && HISTNUMBIT=",..$HISTNUM" || HISTNUMBIT=""
					HISTNUMBIT=
					[ "$HISTCMD" -gt 1 ] && HISTSHOW="($HISTNUM:`history | tail -n 20 | takecols 2 | reverse | removeduplicatelinespo | head -n 5 | head -n "$HISTNUM" | tr '\n' ',' | sed 's+.$++'`$HISTNUMBIT)" || HISTSHOW=
					FAKESQUARE="	"
					# [ "$XTTITLEPROMPT_SIMPLER" ] || XTTITLE_DISPLAY="$XTTITLE_DISPLAY ($LASTCMD)"
					# xttitle "$XTTITLE_HEAD<$((HISTCMD-1))> `swd`%_   $HISTSHOW"

					JOBS_PRE=""
					if [ "$XTTITLEPROMPT_SHOW_JOBS" ]
					then
						JOBS=`jobs | grep -v "^(pwd now: )" | cut -c 19-` # or 31- for bash
						if [ ! "$JOBS" = "" ]
						then
							JOB_LIST="`echo "$JOBS" | tr '\n' ',' | sed 's+,$++'`"
							# JOBS_PRE='&['"$JOB_LIST""] "
							JOBS_PRE='('"$JOB_LIST"")& "
						fi
					fi

					#xttitle "$XTTITLE_HEAD$JOBS_PRE% `swd`/ _   $HISTSHOW"
					## Simplify
					xttitle "$XTTITLE_HEAD$JOBS_PRE`swd`/ _"

					# echo ">$STY<" >> /tmp/123
					# screentitle "[$XTTITLE_HEAD$SHOWUSER$SHOWHOST%`swd | cut -c -10`]"
					# screentitle "[$XTTITLE_HEAD$SHOWUSER$SHOWHOST%`swd | sed 's+.*/\(.*/.*\)+\1+' | cut -c -10`]"
					[ "$SCREENTITLE" ] &&
					SCREEN_TITLE_TMP="$SCREENTITLE" ||
					SCREEN_TITLE_TMP="`swd | sed 's+.*/\(.*/.*\)+\1+ ; s+.*\(..........\)+\1+'`/"
					screentitle "$SCRHEAD$SCREEN_TITLE_TMP"
				fi
			}
		;;

		## For tcsh, use postcmd builtin:
		## Doesn't actually appear 'cos tcsh can't exec this far!
		## See .tcshrc for actual postcmd!
		tcsh)
			alias postcmd 'xttitle "${XTTITLE_HEAD}${USER}@${SHORTHOST}:${PWD}%% \!#"'
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
