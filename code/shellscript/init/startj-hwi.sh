export JPATH=$HOME/j
export JWHICHOS=unix
export PATH=.:$JPATH/tools:$PATH

source getmachineinfo

source joeysaliases
source cvsinit

source zshkeys

# source dirhistorysetup.bash
source dirhistorysetup.zsh
source hwipromptforbash
source hwipromptforzsh
source javainit
source hugsinit
source lscolsinit

# alias hwicvs='cvs -d :pserver:joey@hwi.dyn.dhs.org:/stuff/cvsroot'
alias cvsimc='cvs -d :pserver:anonymous@cat.org.au:/usr/local/cvsroot'
alias cvsenhydra='cvs -d :pserver:anoncvs@enhydra.org:/u/cvs'

mesg y

export FIGNORE=".class"

# source $JPATH/tools/jshellalias
# source $JPATH/tools/jshellsetup
