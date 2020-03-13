# @sourceme

#COLRESET="\[`cursenorm`\]"
COLRESET="\[\033[00m\]"
JOBSCOL="\[$(curseyellow)\]"

USERHOST=""
if ! [ "$USER" = joey ] || [ -n "$SSH_CONNECTION" ]
then USERHOST="${COLOR}\u${OTHERCOLOR}@${COLOR}\h${COLRESET}:"
fi

# Seasonal bat prompt (like an easter egg):
if date | grep "Oct 31" > /dev/null
then
	PS1="${COLRESET}/\[\033[00;35m\]\u${COLRESET})\[\033[00;34m\]at${COLRESET}(\[\033[00;35m\]\h${COLRESET}\\\\ \[\033[00;32m\]\w/${COLRESET} "
	# PS1="${COLRESET}/\[\033[00;35m\]\\/${COLRESET})\[\033[00;34m\]oo${COLRESET}(\[\033[00;35m\]\\/${COLRESET}\\\\ \[\033[00;32m\]\w/${COLRESET} "
else

	if declare -f find_git_branch >/dev/null
	then GIT_AWARE_PROMPT="\[`cursemagenta;cursebold`\]\$git_branch\[`cursegreen``cursebold`\]\$git_ahead_mark\$git_ahead_count\[`cursered``cursebold`\]\$git_behind_mark\$git_behind_count\[`cursecyan`\]\$git_staged_mark\$git_staged_count\[`curseyellow`\]\$git_dirty\$git_dirty_count\[`curseyellow``cursebold`\]\$git_stash_mark\[`curseblue`\]\$git_unknown_mark\$git_unknown_count"
	fi

	# Quite fun:
	# PS1='\['`curseyellow`'\]\!\['`cursered``cursebold`'\]\$\['`cursenorm`'\])\['`cursemagenta`'\]\u\['`cursenorm`'\]-\['`curseblue`'\]\t\['`cursenorm`'\]-\['`cursemagenta`'\]\h\['`cursenorm`'\](\['`cursegreen`'\]\w/\['`cursenorm`'\] '

	# if [ ! "$RUNNING_GENTOO" ]
	# then
		# if uname -r | grep "gentoo" >/dev/null 2>&1
		if [ -f /etc/gentoo-release ]
		then export RUNNING_GENTOO=1
		else export RUNNING_GENTOO=0
		fi
	# fi

		# if test "$HOME" = "/root" # Note: cld use UID=0 but not USER=root!
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
			# G2COL="\[\033[01;32m\]"
			G2COL="\[\033[01;32m\]"
			G2U="\u@"
			G2P=" $"
			G2DIRCOLOR="\[\033[01;34m\]"
		fi

		EXITERR='`[ "$?" = 0 ] || echo "\[\033[01;31m\]<\[\033[01;31m\]<\[\033[01;33m\]$?\[\033[01;31m\]>\[\033[01;31m\]> "`'
		if [ "$RUNNING_GENTOO" = 1 ]
		then
			PS1="$EXITERR$G2COL$G2U\h`curseblack`:$G2DIRCOLOR\w$GIT_AWARE_PROMPT $G2P${COLRESET}"
		else
			## this splash of colours is important!
			# DOLLARDOESNTDOMUCH="\\$" ## should be $ or # depending on uid
			DOLLARDOESNTDOMUCH="\j" ## number of jobs handled by shell
			PS1="$EXITERR$HISTCOL\!$RESCOL$DOLLARDOESNTDOMUCH ${COLRESET}($COLOR\h $OTHERCOLOR\t $COLOR\u${COLRESET}) $DIRCOLOR\w/$GIT_AWARE_PROMPT${COLRESET} "
		fi

	# case `hostname -s` in
	case "$SHORTHOST" in

		panic)
			PS1='\['`curseyellow`'\]\!\['`cursered``cursebold`'\]\$\['`cursenorm`'\]/\['`cursemagenta`'\]\u\['`cursenorm`'\] \['`curseblue`'\]\t\['`cursenorm`'\] \['`cursemagenta`'\]\h\['`cursenorm`'\]\\\\\['`cursegreen`'\]\w\\\\\['`cursenorm`'\] '
			# magenta style, panic colors PS1="\[\033[00;33m\]\!\[\033[01;31m\]\$ \[\033[00;35m\]\u${COLRESET}\\\\\[\033[00;34m\]\t${COLRESET}/\[\033[01;35m\]\h \[\033[00;32m\]\w/${COLRESET} "
		;;

		magenta|colossus)
			# panic style, magenta colors PS1='\['`cursegreen`'\]\$\['`cursecyan`'\]\!\['`cursenorm`'\]/\['`curseblue`'\]\u\['`cursenorm`'\]\\\['`cursemagenta`'\]\t\['`cursenorm`'\]/\['`curseblue`'\]\h\['`cursenorm`'\]\\\\\['`cursecyan`'\]\w/\['`cursenorm`'\] '
			PS1="\[\033[00;32m\]\$\[\033[00;36m\]\! \[\033[01;34m\]\u${COLRESET}\\\\\[\033[00;35m\]\t${COLRESET}/\[\033[01;34m\]\h \[\033[01;36m\]\w\\\\${COLRESET} "
			# Gnome?
			# PS1="\[\033[00;33m\]\!\[\033[01;31m\]\$${COLRESET}(\[\033[00;35m\]\u${COLRESET}|\[\033[00;36m\]\t${COLRESET}|\[\033[00;35m\]\h${COLRESET})\[\033[00;32m\]\w/${COLRESET} "
		;;

		buggy|bristoldev|tronic|rob)
			# PS1='\['`curseblue``cursebold`'\]\!\['`cursegreen``cursebold`'\] (\['`cursegreen`'\](> \['`cursered`'\]\u\['`cursegrey`'\]@\['`cursered`'\]\h\['`cursegreen`'\] <)\['`cursebold`'\]) \['`curseblue``cursebold`'\]\w/\['`cursegrey`'\] '
			# HOME seems more reliable than USER!
			if test "$HOME" = "/root"; then
			PS1='\['`cursecyan`'\]\u\['`curseyellow``cursebold`'\] (\['`curseyellow`'\](> \['`cursered``cursebold`'\]\h\['`curseyellow`'\] <)\['`cursebold`'\]) \['`cursecyan`'\]\w/\['`cursenorm`'\] '
			else
			PS1='\['`cursered``cursebold`'\]\u\['`cursegreen``cursebold`'\] (\['`cursegreen`'\](> \['`curseblue``cursebold`'\]\h\['`cursegreen`'\] <)\['`cursebold`'\]) \['`cursered``cursebold`'\]\w/\['`cursenorm`'\] '
			fi
			# PS1='\['`cursered`'\]\!\['`cursegreen``cursebold`'\] (\['`cursegreen`'\](< \['`curseblue``cursebold`'\]\h\['`cursegreen`'\] >)\['`cursebold`'\]) \['`cursered``cursebold`'\]\w/\['`cursenorm`'\] '
		;;

		*)
			# if test "$HOME" = "/root" # Note: cld use UID=0 but not USER=root!
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
				# G2COL="\[\033[01;32m\]"
				G2COL="\[\033[01;32m\]"
				G2U="\u@"
				G2P=" $"
				G2DIRCOLOR="\[\033[01;34m\]"
			fi

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
			MARKER_BLOCK='$(echo "\[\033[$(if [ "$?" = '0' ]; then echo "42"; else echo "41"; fi);30m\]\t\[\033[00m\] ")'
			EXITERR=""

			if [ "$RUNNING_GENTOO" = 1 ]
			then
				PS1="$EXITERR$G2COL$G2U\h`curseblack`:$G2DIRCOLOR\w$GIT_AWARE_PROMPT $G2P${COLRESET}"
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

			## hwi is a special case where I can be logged in in different ways
			## If ssh-ed into hwi, present some extra prompt to make it clear:
			if [ "$SHORTHOST" = hwi ] && [ -n "$SSH_CONNECTION" ]
			then PS1="$RESCOL<$USER@$SHORTHOST> $PS1"
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
	PS4="+[\[`cursered;cursebold`\]\s${COLRESET}]\[`cursegreen`\]\W${COLRESET}\$ "

fi

if [ -n "$SSH_CONNECTION" ]
then
	if [[ "$PS1" = *\u* ]]
	then : # If the prompt we chose above has already included the hostname, then we don't need to do it here
	else PS1="\[\033[00;36m\]<$USER@$SHORTHOST>${COLRESET} $PS1"
	fi
	export XTTITLE_PRESTRING="<$USER@$SHORTHOST> $XTTITLE_PRESTRING"
fi

PS1="$PREPROMPT$PS1"
