# @sourceme

## Run `bind -P` to print existing bindings.
## Vi mode: http://www.catonmat.net/blog/bash-vi-editing-mode-cheat-sheet/

# Originally in ~/.inputrc with ' 's instead of ':'s
bind "\C-d":backward-word
bind "\C-f":forward-word
bind "\C-r":vi-prev-word
bind "\C-t":vi-next-word
## Delete big word (by whitespace) - but no forward version available
#bind "\C-x":unix-word-rubout
## Delete big word (by whitespace or slash) - but no forward version available
bind "\C-x":unix-filename-rubout
## Delete small words
#bind "\C-x":backward-kill-word
bind "\C-v":kill-word
## We could fake small deletes
# bind "\C-b":"\C-f \C-x"
# bind "\C-z":"\C-d \C-v"
## But these are small deletes anyway
## They can be used when C-x/v are inhibited by Solaris:
bind "\C-z":backward-kill-word
bind "\C-b":kill-word
## My mirror to C-u; actually available as a default on C-k.
## Kinda dangerous to use in case bashkeys are not loaded, because C-o's default action is to run the current command (and load line back up into REPL)!
## Also doesn't work in iTerm2 on Mac.  It might be better just to learn Ctrl-K!
bind "\C-o":kill-line
## Paste (similar to zsh's vi-put-after)
## Default action is previous-history, so you might get that if this hasn't been loaded!
## If that does happen, press Ctrl-n or <Down> to return, then Escape-p to perform vi-put from vi mode.
bind "\C-p":vi-put

## If we did `set -o vi` then we might be able to simulate the deletes we want using Vi mode.  <Esc> to enter vi mode.

bind "\C-space":forward-char
bind "\C-h":backward-char

## Since C-r overrode the reverse-search-history action, make a new bind for it
## Binding C-? also activates when I hit C-/ (in xterm on tomato:Ubuntu-12.04)
bind "\C-?":reverse-search-history
## On no this is no good.  It fires when pressing arrow keys!
#bind "\C-[":reverse-search-history

## These don't seem to work at all here.
## But they work just fine in ~/.inputrc
## Ctrl-Left and -Right
#bind "\e[1;5D":backward-word
#bind "\e[1;5C":forward-word
#bind "\e[5D":backward-word
#bind "\e[5C":forward-word
## Shift-Left and -Right
#bind "\e[1;2D":backward-word
#bind "\e[1;2C":forward-word
#bind "\e[2D":backward-word
#bind "\e[2C":forward-word
