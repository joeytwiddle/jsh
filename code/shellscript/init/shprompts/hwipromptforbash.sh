
# Batman:
date | grep "Oct 31" > /dev/null &&
PS1="\[\033[00m\]/\[\033[00;35m\]\u\[\033[00m\])\[\033[00;34m\]at\[\033[00m\](\[\033[00;35m\]\h\[\033[00m\]\\\\ \[\033[00;32m\]\w/\[\033[00m\] " ||
# PS1="\[\033[00m\]/\[\033[00;35m\]\\/\[\033[00m\])\[\033[00;34m\]oo\[\033[00m\](\[\033[00;35m\]\\/\[\033[00m\]\\\\ \[\033[00;32m\]\w/\[\033[00m\] " ||

# Quite fun:
# PS1='\['`curseyellow`'\]\!\['`cursered``cursebold`'\]\$\['`cursenorm`'\])\['`cursemagenta`'\]\u\['`cursenorm`'\]-\['`curseblue`'\]\t\['`cursenorm`'\]-\['`cursemagenta`'\]\h\['`cursenorm`'\](\['`cursegreen`'\]\w/\['`cursenorm`'\] '

case `hostname -s` in

	panic)
		PS1='\['`curseyellow`'\]\!\['`cursered``cursebold`'\]\$\['`cursenorm`'\]/\['`cursemagenta`'\]\u\['`cursenorm`'\] \['`curseblue`'\]\t\['`cursenorm`'\] \['`cursemagenta`'\]\h\['`cursenorm`'\]\\\\\['`cursegreen`'\]\w\\\\\['`cursenorm`'\] '
		# magenta style, panic colors PS1="\[\033[00;33m\]\!\[\033[01;31m\]\$ \[\033[00;35m\]\u\[\033[00m\]\\\\\[\033[00;34m\]\t\[\033[00m\]/\[\033[01;35m\]\h \[\033[00;32m\]\w/\[\033[00m\] "
	;;

	magenta)
	# if test `hostname` = "colossus" || test "$USER" = "pru"; then
	  # panic style, magenta colors PS1='\['`cursegreen`'\]\$\['`cursecyan`'\]\!\['`cursenorm`'\]/\['`curseblue`'\]\u\['`cursenorm`'\]\\\['`cursemagenta`'\]\t\['`cursenorm`'\]/\['`curseblue`'\]\h\['`cursenorm`'\]\\\\\['`cursecyan`'\]\w/\['`cursenorm`'\] '
	  PS1="\[\033[00;32m\]\$\[\033[00;36m\]\! \[\033[01;34m\]\u\[\033[00m\]\\\\\[\033[00;35m\]\t\[\033[00m\]/\[\033[01;34m\]\h \[\033[01;36m\]\w\\\\\[\033[00m\] "
	  # Gnome?
	  # PS1="\[\033[00;33m\]\!\[\033[01;31m\]\$\[\033[00m\](\[\033[00;35m\]\u\[\033[00m\]|\[\033[00;36m\]\t\[\033[00m\]|\[\033[00;35m\]\h\[\033[00m\])\[\033[00;32m\]\w/\[\033[00m\] "
	;;

	buggy|bristoldev|rob)
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
		if test "$HOME" = "/root"; then # Note: cld use UID=0 but not USER=root!
			PS1="\[\033[01;32m\]\!\[\033[01;33m\]\$ \[\033[00m\](\[\033[01;31m\]\\h \[\033[00;36m\]\t\[\033[01;31m\] \u\[\033[00m\]) \[\033[00;33m\]\w/\[\033[00m\] "
		else
			PS1="\[\033[00;33m\]\!\[\033[01;31m\]\$ \[\033[00m\](\[\033[00;36m\]\\h \[\033[00m\]\t\[\033[00;36m\] \u\[\033[00m\]) \[\033[00;32m\]\w/\[\033[00m\] "
		fi
	;;

esac

# PS1="[\u@\h \W]\\$ "
# PS1="(\h \t \u) \w/ "

export PS1
