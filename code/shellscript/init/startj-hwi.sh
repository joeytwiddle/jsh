# export JPATH=/home/joey/j
export JPATH=$HOME/j
export JWHICHOS=linux
export PATH=.:$JPATH/tools:$PATH

source getmachineinfo

# alias hwicvs='cvs -d :pserver:joey@hwi.dyn.dhs.org:/stuff/cvsroot'
alias cvsimc='cvs -d :pserver:anonymous@cat.org.au:/usr/local/cvsroot'
alias cvsenhydra='cvs -d :pserver:anoncvs@enhydra.org:/u/cvs'

# echo "$JPATH/setpath: initialising J"

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

# mesg y

export FIGNORE=".class"

# source $JPATH/tools/jshellalias
# source $JPATH/tools/jshellsetup

# HUGSFLAGS=-'P/usr/local/share/hugs/lib/:'$JPATH'/install/hugs98/lib:'$JPATH'/install/hugs98/lib/hugs:/usr/local/share/hugs/lib/exts:'$JPATH'/code/hugs -E"pico +%d %s" +s';
# export HUGSFLAGS
# HUGSPATH='/usr/local/share/hugs/lib/:'$JPATH'/install/hugs98/lib:'$JPATH'/install/hugs98/lib/hugs:/usr/local/share/hugs/lib/exts:'$JPATH'/code/hugs';
# export HUGSPATH
