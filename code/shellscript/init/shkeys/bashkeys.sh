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

# The following feature only half works with bash 3.  It confuses me when it is half working (it makes me think it is fully working, and only one completion is possible, when in fact many are), therefore I would rather not use it at all in bash 3.
if ((BASH_VERSINFO[0] >= 4))
then
  # Defaults (to undo the next section, if desired):
  #bind "TAB:complete"
  #bind "set show-all-if-ambiguous off"
  #bind "set menu-complete-display-prefix off"

  # If there are multiple matches for completion, Tab should cycle through them
  bind 'TAB':menu-complete
  # The following only work on bash > 4 (so not on Mac which ships with bash 3 by default)
  # List the files if there is more than one match
  bind "set show-all-if-ambiguous on"
  # If there are multiple matches, do not complete on the first Tab, only start cycling on the second Tab
  bind "set menu-complete-display-prefix on"
  # The following is meant to cycle backwards on Shift-Tab.
  # So far, I have not got this working on bash3 or bash4 under iTerm2, or on Linux!
  #bind '\e[Z':menu-complete-backward
fi
