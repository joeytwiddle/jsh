# @sourceme

#COLRESET="\[`cursenorm`\]"
COLRESET="\[\033[00m\]"
JOBSCOL="\[\033[01;33m\]"

# We use different colours for root, to help root shells to stand out
#if [ "$HOME" = "/root" ]
# Note: cld use UID=0 but not USER=root!
if [ "$UID" = 0 ]
then
	COLOR="\[\033[01;31m\]"
	OTHERCOLOR="\[\033[00;37m\]"
	DIRCOLOR="\[\033[00;36m\]"
	HISTCOL="\[\033[01;31m\]"
	RESCOL="\[\033[01;33m\]"
	G2COL="\[\033[01;31m\]"
	G2U=""
	G2P=" #"
	G2DIRCOLOR="\[\033[01;34m\]"
else
	COLOR="\[\033[00;36m\]"
	OTHERCOLOR="${COLRESET}"
	DIRCOLOR="\[\033[00;32m\]"
	HISTCOL="\[\033[00;33m\]"
	RESCOL="\[\033[01;31m\]"
	G2COL="\[\033[01;32m\]"
	G2U="\u@"
	G2P=" $"
	G2DIRCOLOR="\[\033[01;34m\]"
fi

USERHOST=""
# || [ -n "$SCREEN" ] || [ -n "$TMUX" ]
# || [ "$TERM" = screen ]
#if ! [ "$USER" = joey ] || [ -n "$SSH_CONNECTION" ]
if [ -n "$SSH_CONNECTION" ] #|| ( [ "$USER" != joey ] && [ "$USER" != joey.clark ] )
then USERHOST="${COLOR}\u${OTHERCOLOR}@${COLOR}\h${COLRESET}:"
fi

if declare -f find_git_branch >/dev/null
then GIT_AWARE_PROMPT="\[`cursemagenta;cursebold`\]\$git_branch\[`cursered``cursebold`\]\$git_behind_main_mark\$git_behind_main_count\[`cursegreen``cursebold`\]\$git_ahead_from_main_count\$git_rebased_count\$git_ahead_mark\$git_ahead_count\[`cursered``cursebold`\]\$git_behind_mark\$git_behind_count\[`cursecyan`\]\$git_staged_mark\$git_staged_count\[`curseyellow`\]\$git_dirty\$git_dirty_count\[`curseyellow``cursebold`\]\$git_stash_mark\[`curseblue`\]\$git_unknown_mark\$git_unknown_count\[`cursenorm`\]"
fi

# Seasonal bat prompt (like an easter egg):
if date | grep "Oct 31" > /dev/null
then
	## Bat
	PS1="${COLRESET}/\[\033[00;35m\]\u${COLRESET})\[\033[00;34m\]at${COLRESET}(\[\033[00;35m\]\h${COLRESET}\\\\ \[\033[00;32m\]\w/${COLRESET}${GIT_AWARE_PROMPT} "
	## Spider
	# PS1="${COLRESET}/\[\033[00;35m\]\\/${COLRESET})\[\033[00;34m\]oo${COLRESET}(\[\033[00;35m\]\\/${COLRESET}\\\\ \[\033[00;32m\]\w/${COLRESET}${GIT_AWARE_PROMPT} "
else
	if [ -f /etc/gentoo-release ]
	then export RUNNING_GENTOO=1
	else export RUNNING_GENTOO=0
	fi

	EXITERR='`[ "$?" = 0 ] || echo "\[\033[01;31m\]<\[\033[01;31m\]<\[\033[01;33m\]$?\[\033[01;31m\]>\[\033[01;31m\]> "`'
	if [ "$RUNNING_GENTOO" = 1 ]
	then
		PS1="${EXITERR}${G2COL}${G2U}\h\[`curseblack`\]:${G2DIRCOLOR}\w${GIT_AWARE_PROMPT} ${G2P}${COLRESET}"
	else
		## this splash of colours is important!
		# DOLLARDOESNTDOMUCH="\\$" ## should be $ or # depending on uid
		DOLLARDOESNTDOMUCH="\j" ## number of jobs handled by shell
		PS1="${EXITERR}${HISTCOL}\!${RESCOL}${DOLLARDOESNTDOMUCH} ${COLRESET}($COLOR\h ${OTHERCOLOR}\t ${COLOR}\u${COLRESET}) ${DIRCOLOR}\w/${GIT_AWARE_PROMPT}${COLRESET} "
	fi

	# case `hostname -s` in
	case "$SHORTHOST" in
		*)
			## This gets evaluated on-the-fly:
			EXITERR='`[ "$?" = 0 ] || echo "\[\033[01;31m\]<\[\033[01;31m\]<\[\033[01;33m\]$?\[\033[01;31m\]>\[\033[01;31m\]> "`'
			## (shouldn't all modern bash prompts have this, on the other machines above?)
			## I wanted to put this further right, just before the path, but if I put it there, it always reports 1.
			## That happens because the [ \j -gt 0 ] test sets $?, overwriting the $? from the previous command that we wanted.

			#MARKER_BLOCK="\[\033[47;36m\]     ${COLRESET} "
			#MARKER_BLOCK="\[\033[47;36m\]     ${COLRESET} "
			#MARKER_BLOCK='$([ "$?" = 0 ] && echo -n "\[\033[42;36m\]" || echo -n "\[\033[41;36m\]" ; echo -n "     ${COLRESET} ")'
			#MARKER_BLOCK='$(echo "\[\033[$(("$?" ? 41 : 47));36m\]      ${COLRESET} ")'
			# Works in bash 4
			#MARKER_BLOCK='$(echo "\[\033[$(("$?" ? 41 : 42));30m\]\t${COLRESET} ")'
			# To support bash 3 (macOS) we need to use an if-then-else
			#MARKER_BLOCK='$(echo "\[\033[$(if [ "$?" = '0' ]; then echo "42"; else echo "41"; fi);30m\]\t\[\033[00m\] ")'
			#MARKER_BLOCK='$(if [ "$?" = '0' ]; then echo "\[\033[42;30m\]"; else echo "\[\033[41;30m\]"; fi)\t\[\033[00m\] '
			MARKER_BLOCK='\[\033[$(if [ "$?" = '0' ]; then echo "42"; else echo "41"; fi);30m\]\t\[\033[00m\] '
			# Full line red or green (with timestamp) then prompt on the next line
			# It's pretty good for separation. But one thing I dislike about a two-line prompt is that when quitting 'less' the top line of the less display gets pushed off the screen.
			#MARKER_BLOCK='$(if [ "$?" = '0' ]; then printf "\[\033[48;5;22m\]\t%*s" "$((COLUMNS-8))" " "; else printf "\[\033[48;5;88m\]\t%*s" "$((COLUMNS-8))" " "; fi)\[\033[00m\]\n'
			EXITERR=""

			if [ "$RUNNING_GENTOO" = 1 ]
			then
				PS1="${EXITERR}${G2COL}${G2U}\h\[`curseblack`\]:${G2DIRCOLOR}\w${GIT_AWARE_PROMPT} ${G2P}${COLRESET}"
			else
				## TODO: the problem is that this red field gets confused with jsh's zsh prompt which has the exit code in red and then the path in green
				## this splash of colours is important!
				## i need one of these - i like the red!
				# DOLLARDOESNTDOMUCH="\\$" ## '#' for root, '$' for users - better as an end prompt
				# DOLLARDOESNTDOMUCH="\j" ## number of jobs handled by shell - almost always 0, got it confused with exit code :P
				DOLLARDOESNTDOMUCH=""
				## TODO: can we find a more useful value for DOLLARDOESNTDOMUCH (especially given the on-the-fly evaluation above)?
				[ -n "$PROMPTHOST" ] || PROMPTHOST="\h" ## PROMPTHOST for jchroot, or fallback to standard
				#PS1="$EXITERR$HISTCOL\!$RESCOL$DOLLARDOESNTDOMUCH ${JOBSCOL}\$([ \j -gt 0 ] && echo '[\j] ')${COLRESET}($COLOR$PROMPTHOST $OTHERCOLOR\t $COLOR\u${COLRESET}) $DIRCOLOR\w/$GIT_AWARE_PROMPT${COLRESET} "
				#PS1="$EXITERR$MARKER_BLOCK${JOBSCOL}\$([ \j -gt 0 ] && echo '[\j] ')${COLRESET}$COLOR\u$OTHERCOLOR@$COLOR$PROMPTHOST${COLRESET}:$DIRCOLOR\w/$GIT_AWARE_PROMPT${COLRESET} "
				PS1="${EXITERR}${MARKER_BLOCK}${JOBSCOL}\$([ \j -gt 0 ] && echo '[\j] ')${COLRESET}${USERHOST}${DIRCOLOR}\w/${GIT_AWARE_PROMPT}${COLRESET} "
			fi
		;;
	esac

	# PS1="[\u@\h \W]\\$ "
	# PS1="(\h \t \u) \w/ "

	# if test "$TERM" = screen || test "$STY"
	if [ -n "$STY" ]
	then
		SCREEN_NAME="$(printf "%s\n" "$STY" | afterfirst '\.')"
		# test "$SCREEN_NAME" || SCREEN_NAME=screen
		PS1="[${SCREEN_NAME}${WINDOW}] $PS1"
	fi

	## for sh -x debugging
	# PS4="+\[`cursegreen`\]\W\[`cursenorm`\]\$ " ## see hwipromptforzsh
	#PS4="#[\[`cursered;cursebold`\]\s${COLRESET}]\[`cursegreen`\]\W/${COLRESET}\$ "
	PS4="\[`cursecyan;cursebold`\]###\[${COLRESET}\] "
	export PS4
fi

if [ -n "$USERHOST" ]
then
	if [[ "$PS1" = *\u* ]]
	then : # If the prompt we chose above has already included the hostname, then we don't need to do it here
	else PS1="\[\033[00;36m\]<${USER}@${SHORTHOST}>${COLRESET} ${PS1}"
	fi
	export XTTITLE_PRESTRING="<${USER}@${SHORTHOST}> ${XTTITLE_PRESTRING}"
fi

PS1="${PREPROMPT}${PS1}"
