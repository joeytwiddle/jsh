# Key bindings for zsh

# bindkey -N mymap main # clear keymap
# bindkey -v # viins keymap
# bindkey -e # emacs keymap
# Create custom keymap with viins
# bindkey -N mymap viins

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
# and of course the vim paste!
bindkey "^p" vi-put-after

# My preferred word movement and deletion.
# It's purely left-handed and positioned to avoid the reserved keys qeaszc.
# Oops d is reserved and I use it, but it works OK on Hwi.
# Movement in big jumps
bindkey "^d" vi-backward-word
bindkey "^f" vi-forward-word
# Deletion in small chunks
bindkey "^x" vi-backward-kill-word
# bindkey "^v" kill-word # no vi-kill-forward! (or was I spelling forword?!)
bindkey -s "^v" "^f^x"
# bindkey -s "^v" "^f^x"
# bindkey "^v" "kill-word" # too large

bindkey "^u" vi-undo-change
