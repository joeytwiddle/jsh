
# Seasonal Batman:
date | grep "Oct 31" > /dev/null &&
PS1="\[\033[00m\]/\[\033[00;35m\]\u\[\033[00m\])\[\033[00;34m\]at\[\033[00m\](\[\033[00;35m\]\h\[\033[00m\]\\\\ \[\033[00;32m\]\w/\[\033[00m\] " ||
# PS1="\[\033[00m\]/\[\033[00;35m\]\\/\[\033[00m\])\[\033[00;34m\]oo\[\033[00m\](\[\033[00;35m\]\\/\[\033[00m\]\\\\ \[\033[00;32m\]\w/\[\033[00m\] " ||

# Quite fun:
# PS1='\['`curseyellow`'\]\!\['`cursered``cursebold`'\]\$\['`cursenorm`'\])\['`cursemagenta`'\]\u\['`cursenorm`'\]-\['`curseblue`'\]\t\['`cursenorm`'\]-\['`cursemagenta`'\]\h\['`cursenorm`'\](\['`cursegreen`'\]\w/\['`cursenorm`'\] '

if [ ! "$RUNNING_GENTOO" ]
then
	if uname -r | grep "gentoo" >/dev/null 2>&1
	then export RUNNING_GENTOO=1
	else export RUNNING_GENTOO=0
	fi
fi

# case `hostname -s` in
case "$SHORTHOST" in

	panic)
		PS1='\['`curseyellow`'\]\!\['`cursered``cursebold`'\]\$\['`cursenorm`'\]/\['`cursemagenta`'\]\u\['`cursenorm`'\] \['`curseblue`'\]\t\['`cursenorm`'\] \['`cursemagenta`'\]\h\['`cursenorm`'\]\\\\\['`cursegreen`'\]\w\\\\\['`cursenorm`'\] '
		# magenta style, panic colors PS1="\[\033[00;33m\]\!\[\033[01;31m\]\$ \[\033[00;35m\]\u\[\033[00m\]\\\\\[\033[00;34m\]\t\[\033[00m\]/\[\033[01;35m\]\h \[\033[00;32m\]\w/\[\033[00m\] "
	;;

	magenta|colossus)
	  # panic style, magenta colors PS1='\['`cursegreen`'\]\$\['`cursecyan`'\]\!\['`cursenorm`'\]/\['`curseblue`'\]\u\['`cursenorm`'\]\\\['`cursemagenta`'\]\t\['`cursenorm`'\]/\['`curseblue`'\]\h\['`cursenorm`'\]\\\\\['`cursecyan`'\]\w/\['`cursenorm`'\] '
	  PS1="\[\033[00;32m\]\$\[\033[00;36m\]\! \[\033[01;34m\]\u\[\033[00m\]\\\\\[\033[00;35m\]\t\[\033[00m\]/\[\033[01;34m\]\h \[\033[01;36m\]\w\\\\\[\033[00m\] "
	  # Gnome?
	  # PS1="\[\033[00;33m\]\!\[\033[01;31m\]\$\[\033[00m\](\[\033[00;35m\]\u\[\033[00m\]|\[\033[00;36m\]\t\[\033[00m\]|\[\033[00;35m\]\h\[\033[00m\])\[\033[00;32m\]\w/\[\033[00m\] "
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
		if test "$HOME" = "/root" # Note: cld use UID=0 but not USER=root!
		then
			COLOR="\[\033[01;31m\]"
			OTHERCOLOR="\[\033[00;36m\]"
			DIRCOLOR="\[\033[00;36m\]"
			HISTCOL="\[\033[01;31m\]"
			RESCOL="\[\033[01;33m\]"
			G2COL="\[\033[01;31m\]"
			G2U=""
			G2P=" #"
			G2DIRCOLOR="\[\033[01;34m\]"
		else
			COLOR="\[\033[00;36m\]"
			OTHERCOLOR="\[\033[00m\]"
			DIRCOLOR="\[\033[00;32m\]"
			HISTCOL="\[\033[00;33m\]"
			RESCOL="\[\033[01;31m\]"
			# G2COL="\[\033[01;32m\]"
			G2COL="\[\033[01;32m\]"
			G2U="\u@"
			G2P=" $"
			G2DIRCOLOR="\[\033[01;34m\]"
		fi
		EXITERR='`[ "$?" = 0 ] || echo "\[\033[00;37m\][\[\033[01;31m\]>\[\033[01;31m\]$?\[\033[01;31m\]<\[\033[00;37m\]] "`'
		if [ "$RUNNING_GENTOO" = 1 ]
		then
			PS1="$EXITERR$G2COL$G2U\h`curseblack`:$G2DIRCOLOR\w$G2COL$G2P \[\033[00m\]"
		else
			DOLLARDOESNTDOMUCH="\$"
			PS1="$EXITERR $HISTCOL\!$RESCOL$DOLLARDOESNTDOMUCH \[\033[00m\]($COLOR\h $OTHERCOLOR\t $COLOR\u\[\033[00m\]) $DIRCOLOR\w/\[\033[00m\] "
		fi
	;;

esac

# PS1="[\u@\h \W]\\$ "
# PS1="(\h \t \u) \w/ "


# if test "$TERM" = screen || test "$STY"
if [ "$STY" ]
then
	SCREEN_NAME=`echo "$STY" | afterfirst '\.'`
	# test "$SCREEN_NAME" || SCREEN_NAME=screen
	PS1="[$SCREEN_NAME$WINDOW] $PS1"
fi

export PS1

## for sh -x debugging
export PS4="% "
