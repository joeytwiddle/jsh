
# Batman:
# PS1="\[\033[00m\]/\[\033[00;35m\]\u\[\033[00m\])\[\033[00;34m\]at\[\033[00m\](\[\033[00;35m\]\h\[\033[00m\]\\\\ \[\033[00;32m\]\w/\[\033[00m\] "

# Quite fun:
# PS1='\['`curseyellow`'\]\!\['`cursered``cursebold`'\]\$\['`cursegrey`'\])\['`cursemagenta`'\]\u\['`cursegrey`'\]-\['`curseblue`'\]\t\['`cursegrey`'\]-\['`cursemagenta`'\]\h\['`cursegrey`'\](\['`cursegreen`'\]\w/\['`cursegrey`'\] '

case `hostname -s` in

	panic)
		PS1='\['`curseyellow`'\]\!\['`cursered``cursebold`'\]\$\['`cursegrey`'\]/\['`cursemagenta`'\]\u\['`cursegrey`'\] \['`curseblue`'\]\t\['`cursegrey`'\] \['`cursemagenta`'\]\h\['`cursegrey`'\]\\\\\['`cursegreen`'\]\w\\\\\['`cursegrey`'\] '
		# magenta style, panic colors PS1="\[\033[00;33m\]\!\[\033[01;31m\]\$ \[\033[00;35m\]\u\[\033[00m\]\\\\\[\033[00;34m\]\t\[\033[00m\]/\[\033[01;35m\]\h \[\033[00;32m\]\w/\[\033[00m\] "
	;;

	magenta)
	# if test `hostname` = "colossus" || test "$USER" = "pru"; then
	  # panic style, magenta colors PS1='\['`cursegreen`'\]\$\['`cursecyan`'\]\!\['`cursegrey`'\]/\['`curseblue`'\]\u\['`cursegrey`'\]\\\['`cursemagenta`'\]\t\['`cursegrey`'\]/\['`curseblue`'\]\h\['`cursegrey`'\]\\\\\['`cursecyan`'\]\w/\['`cursegrey`'\] '
	  PS1="\[\033[00;32m\]\$\[\033[00;36m\]\! \[\033[01;34m\]\u\[\033[00m\]\\\\\[\033[00;35m\]\t\[\033[00m\]/\[\033[01;34m\]\h \[\033[01;36m\]\w\\\\\[\033[00m\] "
	  # Gnome?
	  # PS1="\[\033[00;33m\]\!\[\033[01;31m\]\$\[\033[00m\](\[\033[00;35m\]\u\[\033[00m\]|\[\033[00;36m\]\t\[\033[00m\]|\[\033[00;35m\]\h\[\033[00m\])\[\033[00;32m\]\w/\[\033[00m\] "
	;;

	buggy|bristoldev)
		# PS1='\['`curseblue``cursebold`'\]\!\['`cursegreen``cursebold`'\] (\['`cursegreen`'\](> \['`cursered`'\]\u\['`cursegrey`'\]@\['`cursered`'\]\h\['`cursegreen`'\] <)\['`cursebold`'\]) \['`curseblue``cursebold`'\]\w/\['`cursegrey`'\] '
		# HOME seems more reliable than USER!
		if test "$HOME" = "/root"; then
		PS1='\['`cursecyan`'\]\u\['`curseyellow``cursebold`'\] (\['`curseyellow`'\](> \['`cursered``cursebold`'\]\h\['`curseyellow`'\] <)\['`cursebold`'\]) \['`cursecyan``cursebold`'\]\w/\['`cursegrey`'\] '
		else
		PS1='\['`cursered`'\]\u\['`cursegreen``cursebold`'\] (\['`cursegreen`'\](> \['`curseblue``cursebold`'\]\h\['`cursegreen`'\] <)\['`cursebold`'\]) \['`cursered``cursebold`'\]\w/\['`cursegrey`'\] '
		fi
		# PS1='\['`cursered`'\]\!\['`cursegreen``cursebold`'\] (\['`cursegreen`'\](< \['`curseblue``cursebold`'\]\h\['`cursegreen`'\] >)\['`cursebold`'\]) \['`cursered``cursebold`'\]\w/\['`cursegrey`'\] '
	;;

	*)
		PS1="\[\033[00;33m\]\!\[\033[01;31m\]\$ \[\033[00m\](\[\033[00;36m\]\\h \[\033[00m\]\t\[\033[00;36m\] \u\[\033[00m\]) \[\033[00;32m\]\w/\[\033[00m\] "
	;;

esac

# PS1="[\u@\h \W]\\$ "
# PS1="(\h \t \u) \w/ "

export PS1
