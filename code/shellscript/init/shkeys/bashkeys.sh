# @sourceme

## Instead of using these, better learn the defaults: https://twitter.com/xor/status/957013983327858689

## Run `bind -P` to print existing bindings.
## A good cheatsheet is here: http://teohm.com/blog/2012/01/04/shortcuts-to-move-faster-in-bash-command-line/
## Vi mode: http://www.catonmat.net/blog/bash-vi-editing-mode-cheat-sheet/

## Run `set -o emacs` to reset to defaults, or `set -o vi` to reset to alternative defaults.

# Unset keybindings which get in the way of my keybindings
# I think these should have worked, but they don't!
#while read -r keysym; do bind -r "$keysym"; done < <( bind -p | grep '^"\\C-x' | cut -d ':' -f 1 )
#while read -r keysym; do bind -u "$keysym"; done < <( bind -p | grep '^"\\C-x' | cut -d ':' -f 2 )
bind -r "\C-x\C-g"
bind -r "\C-x\C-?"
bind -r "\C-x\C-v"
bind -r "\C-x\C-e"
bind -r "\C-x)"
bind -r "\C-x\C-x"
bind -r "\C-x*"
bind -r "\C-x!"
bind -r "\C-x/"
bind -r "\C-x@"
bind -r "\C-x~"
bind -r "\C-x$"
bind -r "\C-x\C-r"
bind -r "\C-x("
bind -r "\C-x\C-u"
bind -r "\C-xe"
bind -r "\C-xA"
bind -r "\C-xB"
bind -r "\C-xC"
bind -r "\C-xD"
bind -r "\C-xE"
bind -r "\C-xF"
bind -r "\C-xG"
bind -r "\C-xH"
bind -r "\C-xI"
bind -r "\C-xJ"
bind -r "\C-xK"
bind -r "\C-xL"
bind -r "\C-xM"
bind -r "\C-xN"
bind -r "\C-xO"
bind -r "\C-xP"
bind -r "\C-xQ"
bind -r "\C-xR"
bind -r "\C-xS"
bind -r "\C-xT"
bind -r "\C-xU"
bind -r "\C-xV"
bind -r "\C-xW"
bind -r "\C-xX"
bind -r "\C-xY"
bind -r "\C-xZ"
bind -r "\C-xg"
# But even with all of them removed, Ctrl-X still pauses before executing the command I asked it to!

# Originally in ~/.inputrc with ' 's instead of ':'s
# Instead of using these shortcuts to jump words, you can see if Ctrl-Left/Right works on your system
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
# This actually changes the behaviour of Ctrl-H as well as Ctrl-Backspace.
# But I'm learning to touch-type.  To avoid reaching for Backspace, it is preferable if Ctrl-H deletes the previous char.
#bind "\C-h":backward-char

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

## Up and Down arrows filter by text before cursor
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

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
