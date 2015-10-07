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
## My mirror to C-u; although default is C-k.
bind "\C-o":kill-line
## Kinda dangerous to use in case bashkeys are not loaded, because C-o's default action is to run the current command (and load line back up into REPL)!

## If we did `set -o vi` then we might be able to simulate the deletes we want using Vi mode.  <Esc> to enter vi mode.

bind "\C-space":forward-char
bind "\C-h":backward-char

## Since C-r overrode the reverse-search-history action, make a new bind for it
## Binding C-? also activates when I hit C-/ (in xterm on tomato:Ubuntu-12.04)
bind "\C-?":reverse-search-history
## On no this is no good.  It fires when pressing arrow keys!
#bind "\C-[":reverse-search-history
