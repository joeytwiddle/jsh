export JPATH=/home/joey/j
export JWHICHOS=linux
export PATH=.:$JPATH/tools:$PATH

# alias hwicvs='cvs -d :pserver:joey@hwi.dyn.dhs.org:/stuff/cvsroot'
alias cvsimc='cvs -d :pserver:anonymous@cat.org.au:/usr/local/cvsroot'
alias cvsenhydra='cvs -d :pserver:anoncvs@enhydra.org:/u/cvs'

# echo "$JPATH/setpath: initialising J"

source joeysaliases
source cvsinit

# Key bindings for zsh

# bindkey -N mymap main # clear keymap
# bindkey -v # viins keymap
# bindkey -e # emacs keymap

# Create custom keymap with viins
bindkey -N mymap viins

# Clear all CTRL+Xs from viins keymap to leave CTRL+X free for me
bindkey "^X^B" undefined-key # vi-match-bracket
bindkey "^X^F" undefined-key # vi-find-next-char
bindkey "^X^J" undefined-key # vi-join
bindkey "^X^K" undefined-key # kill-buffer
bindkey "^X^N" undefined-key # infer-next-history
bindkey "^X^O" undefined-key # overwrite-mode
bindkey "^X^U" undefined-key # undo
bindkey "^X^V" undefined-key # vi-cmd-mode
bindkey "^X^X" undefined-key # exchange-point-and-mark
bindkey "^X*" undefined-key # expand-word
bindkey "^X=" undefined-key # what-cursor-position
bindkey "^XG" undefined-key # list-expand
bindkey "^Xg" undefined-key # list-expand
bindkey "^Xr" undefined-key # history-incremental-search-backward
bindkey "^Xs" undefined-key # history-incremental-search-forward
bindkey "^Xu" undefined-key # undo

# Mode switching
bindkey -a "\E" vi-insert
bindkey "\E" vi-cmd-mode # escape
bindkey "^ " vi-cmd-mode

# Vim-like movement if CTRL held
bindkey "^w" forward-word
bindkey "^b" backward-word
bindkey "^x" kill-word
bindkey "^r" expand-history

# My preferred word movement and deletion.
# It's purely left-handed and positioned to avoid the reserved keys qeaszc.
# Oops d is reserved and I use it, but it works OK on Hwi.
# Movement in big jumps
bindkey "^d" backward-word
bindkey "^f" forward-word
# Deletion in small chunks
bindkey "^x" vi-backward-kill-word
bindkey "^v" kill-word

bindkey "^u" vi-undo-change

# trying to jump words with CTRL+arrows
# bindkey "^[OC" backward-word
# bindkey "^[[C" forward-word

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
