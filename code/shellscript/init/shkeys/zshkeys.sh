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

# Clear all CTRL+[s cos I want to use them
# nah this loses loads of stuff i like and doesn't fully clear ^[
# bindkey "^[" undefined-key # vi-backward-kill-word
# bindkey "^[^D" undefined-key # list-choices
# bindkey "^[^G" undefined-key # send-break
# bindkey "^[^H" undefined-key # backward-kill-word
# bindkey "^[^I" undefined-key # self-insert-unmeta
# bindkey "^[^J" undefined-key # self-insert-unmeta
# bindkey "^[^L" undefined-key # clear-screen
# bindkey "^[^M" undefined-key # self-insert-unmeta
# bindkey "^[^_" undefined-key # copy-prev-word
# bindkey "^[ " undefined-key # expand-history
# bindkey "^[!" undefined-key # expand-history
# bindkey "^[\"" undefined-key # quote-region
# bindkey "^[\$" undefined-key # spell-word
# bindkey "^['" undefined-key # quote-line
# bindkey "^[-" undefined-key # neg-argument
# bindkey "^[." undefined-key # insert-last-word
# bindkey "^[0" undefined-key # digit-argument
# bindkey "^[1" undefined-key # digit-argument
# bindkey "^[2" undefined-key # digit-argument
# bindkey "^[3" undefined-key # digit-argument
# bindkey "^[4" undefined-key # digit-argument
# bindkey "^[5" undefined-key # digit-argument
# bindkey "^[6" undefined-key # digit-argument
# bindkey "^[7" undefined-key # digit-argument
# bindkey "^[8" undefined-key # digit-argument
# bindkey "^[9" undefined-key # digit-argument
# bindkey "^[<" undefined-key # beginning-of-buffer-or-history
# bindkey "^[>" undefined-key # end-of-buffer-or-history
# bindkey "^[?" undefined-key # which-command
# bindkey "^[A" undefined-key # accept-and-hold
# bindkey "^[B" undefined-key # backward-word
# bindkey "^[C" undefined-key # capitalize-word
# bindkey "^[D" undefined-key # kill-word
# bindkey "^[F" undefined-key # forward-word
# bindkey "^[G" undefined-key # get-line
# bindkey "^[H" undefined-key # run-help
# bindkey "^[L" undefined-key # down-case-word
# bindkey "^[N" undefined-key # history-search-forward
# bindkey "^[OA" undefined-key # up-line-or-history
# bindkey "^[OB" undefined-key # down-line-or-history
# bindkey "^[OC" undefined-key # forward-char
# bindkey "^[OD" undefined-key # backward-char
# bindkey "^[OF" undefined-key # end-of-line
# bindkey "^[OH" undefined-key # beginning-of-line
# bindkey "^[P" undefined-key # history-search-backward
# bindkey "^[Q" undefined-key # push-line
# bindkey "^[S" undefined-key # spell-word
# bindkey "^[T" undefined-key # transpose-words
# bindkey "^[U" undefined-key # up-case-word
# bindkey "^[W" undefined-key # copy-region-as-kill
# bindkey "^[[3~" undefined-key # delete-char
# # bindkey "^[[A" undefined-key # up-line-or-history
# # bindkey "^[[B" undefined-key # down-line-or-history
# # bindkey "^[[C" undefined-key # forward-char
# # bindkey "^[[D" undefined-key # backward-char
# bindkey "^[_" undefined-key # insert-last-word
# bindkey "^[a" undefined-key # accept-and-hold
# bindkey "^[b" undefined-key # backward-word
# bindkey "^[c" undefined-key # capitalize-word
# bindkey "^[d" undefined-key # kill-word
# bindkey "^[f" undefined-key # forward-word
# bindkey "^[g" undefined-key # get-line
# bindkey "^[h" undefined-key # run-help
# bindkey "^[l" undefined-key # down-case-word
# bindkey "^[n" undefined-key # history-search-forward
# bindkey "^[p" undefined-key # history-search-backward
# bindkey "^[q" undefined-key # push-line
# bindkey "^[s" undefined-key # spell-word
# bindkey "^[t" undefined-key # transpose-words
# bindkey "^[u" undefined-key # up-case-word
# bindkey "^[w" undefined-key # copy-region-as-kill
# bindkey "^[x" undefined-key # execute-named-cmd
# bindkey "^[y" undefined-key # yank-pop
# bindkey "^[z" undefined-key # execute-last-named-cmd
# bindkey "^[|" undefined-key # vi-goto-column
# bindkey "^[^?" undefined-key # backward-kill-word

# Mode switching
bindkey -a "\E" vi-insert
bindkey "\E" vi-cmd-mode # escape
bindkey "^ " vi-cmd-mode

# # Vim-like movement if CTRL held
# bindkey "^w" forward-word
# bindkey "^b" backward-word
# bindkey "^x" kill-word
bindkey "^ " forward-char

# and other Vi usefuls:
bindkey "^p" vi-put-after
bindkey "^p" vi-put-before
bindkey "^h" expand-history
bindkey "^u" vi-undo-change # now taken
bindkey "^z" vi-undo-change # now taken
bindkey "^r" vi-undo-change

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

# The lot, spanning zxdfv nhjkl yuo
# Shorter here thanx to CTRL+arrow below:
# bindkey "^x" backward-kill-word
# bindkey "^d" backward-word
# bindkey "^f" forward-word
bindkey "^z" vi-backward-kill-word
bindkey "^x" backward-kill-word
bindkey "^d" vi-backward-word
bindkey "^f" vi-forward-word
bindkey "^v" kill-word
# there is no vi-kill-word so we fake it
# approximation
bindkey -s "^b" "^f^x"
# And to keep inline:
bindkey -s "^z" "^d^v"
# no good:
# bindkey -s "^v" "^f^x ^[[D"

# bindkey "^n" vi-backward-kill-word
# bindkey "^h" backward-word
# bindkey "^j" vi-backward-word
# bindkey "^k" vi-forward-word
# bindkey "^l" forward-word
bindkey "^u" backward-kill-line
bindkey "^o" kill-line

# Had trouble getting [ fully cleared for:
# bindkey "^p" vi-backward-kill-word
# bindkey "^[" vi-backward-word
# bindkey "^]" vi-forward-word

# At last, bindkey on CTRL+arrow
bindkey "^[[5D" backward-word
bindkey "^[[5C" forward-word
# And at last, fake vi-kill-word using vi-forward-word and vi-backward-kill-word of course!
# Bad at end of line.
# Um yes nasty!
# bindkey -s "^v" "^f^x"
