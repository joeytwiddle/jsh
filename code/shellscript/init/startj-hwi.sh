export JPATH=$HOME/j
# export JWHICHOS=unix
export PATH=.:$JPATH/tools:$PATH

# Don't know why Debian lost this pathdir:
export PATH=$PATH:/usr/X11R6/bin/

source getmachineinfo

source joeysaliases
source cvsinit

source zshkeys

# source dirhistorysetup.bash
source dirhistorysetup.zsh
if endswith "$SHELL" "/bash"
	source hwipromptforbash
elif endswith "$SHELL" = "/zsh"
	source hwipromptforzsh
fi
source javainit
source hugsinit
source lscolsinit

alias hwicvs='cvs -d :pserver:joey@hwi.dyn.dhs.org:/stuff/cvsroot'
alias cvsimc='cvs -d :pserver:anonymous@cat.org.au:/usr/local/cvsroot'
alias cvsenhydra='cvs -d :pserver:anoncvs@enhydra.org:/u/cvs'

# Avoid error if not on a tty
if test ! "$BAUD" = "0"; then
	mesg y
fi

export FIGNORE=".class"

# source $JPATH/tools/jshellalias
# source $JPATH/tools/jshellsetup
