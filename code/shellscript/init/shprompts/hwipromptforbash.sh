# For scp:
# PS1="\[\033[00;36m\]\u\[\033[00;37m\]@\[\033[00;36m\]\h\[\033[00;39m\]:\[\033[00;32m\]\w/\[\033[00;37m\] "
# \[\033[00;36m\]\t\[\033[00;37m\]
# \[\033[00;33m\]\!\[\033[01;31m\]\$

# Batman:
# PS1="\[\033[00m\]/\[\033[00;35m\]\u\[\033[00;37m\])\[\033[00;34m\]at\[\033[00;37m\](\[\033[00;35m\]\h\[\033[00;37m\]\\\\ \[\033[00;32m\]\w/\[\033[00;37m\] "

# Hwi:
# Now everywhere:
# if test `hostname` = "Hwi" -o `hostname` = "hwi.dyn.dhs.org"; then
PS1="\[\033[00;33m\]\!\[\033[01;31m\]\$ \[\033[00;37m\](\[\033[00;36m\]\\h \[\033[00;37m\]\t\[\033[00;36m\] \u\[\033[00;37m\]) \[\033[00;32m\]\w/\[\033[00;37m\] "
# fi

# Quite fun:
# PS1='\['`curseyellow`'\]\!\['`cursered``cursebold`'\]\$\['`cursegrey`'\])\['`cursemagenta`'\]\u\['`cursegrey`'\]-\['`curseblue`'\]\t\['`cursegrey`'\]-\['`cursemagenta`'\]\h\['`cursegrey`'\](\['`cursegreen`'\]\w/\['`cursegrey`'\] '

# Panic:
if test `hostname` = "panic"; then
  PS1='\['`curseyellow`'\]\!\['`cursered``cursebold`'\]\$\['`cursegrey`'\]/\['`cursemagenta`'\]\u\['`cursegrey`'\] \['`curseblue`'\]\t\['`cursegrey`'\] \['`cursemagenta`'\]\h\['`cursegrey`'\]\\\\\['`cursegreen`'\]\w\\\\\['`cursegrey`'\] '
  # magenta style, panic colors PS1="\[\033[00;33m\]\!\[\033[01;31m\]\$ \[\033[00;35m\]\u\[\033[01;37m\]\\\\\[\033[00;34m\]\t\[\033[01;37m\]/\[\033[01;35m\]\h \[\033[00;32m\]\w/\[\033[01;37m\] "
fi

if test `hostname` = "magenta" -o "$USER" = "pru"; then
# if test `hostname` = "colossus" || test "$USER" = "pru"; then
  # panic style, magenta colors PS1='\['`cursegreen`'\]\$\['`cursecyan`'\]\!\['`cursegrey`'\]/\['`curseblue`'\]\u\['`cursegrey`'\]\\\['`cursemagenta`'\]\t\['`cursegrey`'\]/\['`curseblue`'\]\h\['`cursegrey`'\]\\\\\['`cursecyan`'\]\w/\['`cursegrey`'\] '
  PS1="\[\033[00;32m\]\$\[\033[00;36m\]\! \[\033[01;34m\]\u\[\033[01;37m\]\\\\\[\033[00;35m\]\t\[\033[01;37m\]/\[\033[01;34m\]\h \[\033[01;36m\]\w\\\\\[\033[01;37m\] "
  # Gnome?
  # PS1="\[\033[00;33m\]\!\[\033[01;31m\]\$\[\033[00;37m\](\[\033[00;35m\]\u\[\033[00;37m\]|\[\033[00;36m\]\t\[\033[00;37m\]|\[\033[00;35m\]\h\[\033[00;37m\])\[\033[00;32m\]\w/\[\033[00;37m\] "
fi

if test `hostname` = "buggy"; then
	# PS1='\['`curseblue``cursebold`'\]\!\['`cursegreen``cursebold`'\] (\['`cursegreen`'\](> \['`cursered`'\]\u\['`cursegrey`'\]@\['`cursered`'\]\h\['`cursegreen`'\] <)\['`cursebold`'\]) \['`curseblue``cursebold`'\]\w/\['`cursegrey`'\] '
	PS1='\['`cursered`'\]\!\['`cursegreen``cursebold`'\] (\['`cursegreen`'\](> \['`curseblue``cursebold`'\]\h\['`cursegreen`'\] <)\['`cursebold`'\]) \['`cursered``cursebold`'\]\w/\['`cursegrey`'\] '
	# PS1='\['`cursered`'\]\!\['`cursegreen``cursebold`'\] (\['`cursegreen`'\](< \['`curseblue``cursebold`'\]\h\['`cursegreen`'\] >)\['`cursebold`'\]) \['`cursered``cursebold`'\]\w/\['`cursegrey`'\] '
fi

# PS1="[\u@\h \W]\\$ "
# PS1="(\h \t \u) \w/ "

export PS1
