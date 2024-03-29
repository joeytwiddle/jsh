# @sourceme

# Key bindings for zsh

# Note already reserved:
# CTRL+
#	ae(move beg/end line) zc(suspend/kill job) l(refresh) i(tab)m(return)

# bindkey -N mymap main # clear keymap
# bindkey -v # viins keymap
# bindkey -e # emacs keymap
# Create custom keymap with viins
# bindkey -N mymap viins

# Clear all CTRL+Xs from viins keymap to leave CTRL+X free for me!
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

# More when I used zsh 4.3.17 on Ubuntu 12.04
bindkey "^X^R" undefined-key # _read_comp
bindkey "^X?" undefined-key # _complete_debug
bindkey "^XC" undefined-key # _correct_filename
bindkey "^Xa" undefined-key # _expand_alias
bindkey "^Xc" undefined-key # _correct_word
bindkey "^Xd" undefined-key # _list_expansions
bindkey "^Xe" undefined-key # _expand_word
bindkey "^Xh" undefined-key # _complete_help
bindkey "^Xm" undefined-key # _most_recent_file
bindkey "^Xn" undefined-key # _next_tags
bindkey "^Xt" undefined-key # _complete_tag
bindkey "^X~" undefined-key # _bash_list-choices

# Clear all CTRL+[s cos I want to use it.
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

# These only work for me if I hit them really quickly.  Otherwise some other feature gets invoked.
#bindkey "^[?" history-incremental-search-backward
#bindkey "^[/" history-incremental-search-forward
# Very easy to hit:
bindkey "^[^]" history-incremental-search-backward
# "^/" didn't work for me, but ^? (Ctrl-Shift-/) does:
# Oh no, this is no good.  That also gets fired on Delete!
#bindkey "^?" history-incremental-search-backward

# Mode switching
bindkey -a "\E" vi-insert
bindkey "\E" vi-cmd-mode # escape
bindkey "^ " vi-cmd-mode

# # Vim-like movement if CTRL held
# bindkey "^w" forward-word
# bindkey "^b" backward-word
# bindkey "^x" kill-word
bindkey "^ " forward-char # Ctrl+SPACE
bindkey "^@" forward-char # Ctrl+SPACE
# This actually changes the behaviour of Ctrl-H as well as Ctrl-Backspace.
# But I'm learning to touch-type.  To avoid reaching for Backspace, it is preferable if Ctrl-H deletes the previous char.
#bindkey "^H" backward-char # Ctrl+BACKSPACE

# and other Vi usefuls:
#bindkey "^p" vi-put-before
bindkey "^p" vi-put-after
bindkey "^g" expand-history
bindkey "^u" vi-undo-change # now taken
bindkey "^z" vi-undo-change # now taken
bindkey "^r" vi-undo-change # now taken
bindkey "^y" vi-undo-change

# My preferred word movement and deletion.
# It's purely left-handed and positioned to avoid the reserved keys qeaszc.
# Oops d is reserved and I use it, but it works OK on Hwi.
# Movement in big jumps
# Deletion in small chunks
bindkey "^x" vi-backward-kill-word
# bindkey "^v" kill-word # no vi-kill-forward!

# The lot, spanning zxdfv nhjkl yuo
bindkey "^z" backward-kill-word
bindkey "^x" vi-backward-kill-word
bindkey "^d" backward-word
bindkey "^f" forward-word
bindkey "^r" vi-backward-word
bindkey "^t" vi-forward-word
# Solaris zsh complains (after all it don't exist!):
# bindkey "^v" vi-kill-word
# Unfortunately, there is no vi-kill-word, so we fake it:
bindkey -s "^v" "^t^z"
bindkey "^b" kill-word
# and to keep inline, we fake the other too:
bindkey -s "^z" "^r^v"

bindkey "^u" backward-kill-line # (available by default on ^k)
bindkey "^o" kill-line

# Had trouble getting [ fully cleared for:
# bindkey "^p" vi-backward-kill-word
# bindkey "^[" vi-backward-word
# bindkey "^]" vi-forward-word

# Jump back/forward a word using Ctrl-Left and -Right
bindkey "^[[5D" backward-word
bindkey "^[[5C" forward-word
# Except sometimes it's not that, it's this
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word

# Jump back/forward a word using Shift-Left and -Right
bindkey "^[[2D" backward-word
bindkey "^[[2C" forward-word
bindkey "^[[1;2D" backward-word
bindkey "^[[1;2C" forward-word

# Jump back/forward a word using Ctrl-Shift-Left and -Right
bindkey "^[[6D" backward-word
bindkey "^[[6C" forward-word
bindkey "^[[1;6D" backward-word
bindkey "^[[1;6C" forward-word

# Cycle back through completion with Shift-Tab
bindkey '^[[Z' reverse-menu-complete

# Cycle through history based on characters already typed on the line
# https://unix.stackexchange.com/questions/16101/zsh-search-history-on-up-and-down-keys/
#
# Approach 1
# ISSUE: If you press <Up> on an empty line (macOS 2023) the cursor will remain at the start of the line.  We would prefer the cursor jump to the end of the line, which is what up-line-or-beginning-search below does.
#bindkey "$terminfo[kcuu1]" history-beginning-search-backward
#bindkey "$terminfo[kcud1]" history-beginning-search-forward
# On macOS, the terminfo method did not work for me, so I switched to this instead
#bindkey "^[[A" history-beginning-search-backward
#bindkey "^[[B" history-beginning-search-forward
#
# Approach 2
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
#bindkey "$terminfo[kcuu1]" up-line-or-beginning-search
#bindkey "$terminfo[kcud1]" down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

# On my last system the Up and Down keys were "OA" and "OB".
# However it is more portable to use the dynamic values available in $terminfo
# More at: https://raw.githubusercontent.com/sorin-ionescu/prezto/28a20b48e652a01216a6c3dd76e6324d76c12def/modules/editor/init.zsh

# TODO: Ask on stackexchange how to bind CTRL-1, CTRL-2, CTRL-3 to jump to the first, second, third word breaks
# I tried these but with no success:
#bindkey -s "^1" "^a^f"
#bindkey -s "" "^a^a^a^a^a^a^a^f"

# Something had defined this: bindkey "^A" self-insert
# Apparently it wasn't done by: ~/.zsh/zsh-autosuggestions/autosuggestions.zsh
# Anyway we want the default, so let's restore it:
bindkey "^A" beginning-of-line
