# Key bindings for zsh

# Note already reserved:
# CTRL+
#	ae(move beg/end line) zc(suspend/kill job) l(refresh) i(tab)m(return)

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

# # Vim-like movement if CTRL held
# bindkey "^w" forward-word
# bindkey "^b" backward-word
# bindkey "^x" kill-word

# and other Vi usefuls:
bindkey "^p" vi-put-before
bindkey "^r" expand-history
bindkey "^u" vi-undo-change

# My preferred word movement and deletion.
# It's purely left-handed and positioned to avoid the reserved keys qeaszc.
# Oops d is reserved and I use it, but it works OK on Hwi.
# Movement in big jumps
bindkey "^d" backward-word
bindkey "^f" forward-word
# bindkey "^d" vi-backward-word
# bindkey "^f" vi-forward-word
# Deletion in small chunks
bindkey "^x" vi-backward-kill-word
# bindkey "^v" kill-word # no vi-kill-forward!
# approximation
bindkey -s "^v" "^f^x"
# no good:
# bindkey -s "^v" "^f^x ^[[D"

# # Alternative funky attempt, not diagonalised
# bindkey "^d" vi-backward-word
# bindkey "^f" forward-word
# bindkey "^x" vi-backward-kill-word
# bindkey "^v" kill-word

# Alternative funky attempt, diagonalised as it were
# bindkey "^d" backward-word
# bindkey "^f" vi-forward-word
# bindkey "^x" vi-backward-kill-word
# bindkey "^v" kill-word

# The lot, spanning zx sdfg vb
# bindkey "^z" backward-kill-word
# bindkey "^x" vi-backward-kill-word
# bindkey "^s" backward-word
# bindkey "^d" vi-backward-word
# bindkey "^f" vi-forward-word
# bindkey "^g" forward-word
# bindkey "^v" vi-kill-word
# bindkey "^b" kill-word

# The lot, spanning er df zx vb (w instead of z?)
# bindkey "^d" backward-word
# bindkey "^f" forward-word
# bindkey "^e" vi-backward-word
# bindkey "^r" vi-forward-word
# bindkey "^x" backward-kill-word
# bindkey "^v" kill-word
# # bindkey "^z" vi-backward-kill-word
# bindkey "^w" vi-backward-kill-word
# bindkey "^b" vi-kill-word
# # and since we replace e:
# bindkey "^g" end-of-line

# The lot, spanning df  hjkl yuo n,
bindkey "^d" backward-word
bindkey "^f" forward-word
bindkey "^h" backward-word
bindkey "^j" vi-backward-word
bindkey "^k" vi-forward-word
bindkey "^l" forward-word
bindkey "^y" backward-kill-word
bindkey "^u" vi-backward-kill-word
bindkey "^o" kill-word
bindkey "^n" backward-kill-line
bindkey "^," kill-line
