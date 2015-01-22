# @sourceme

# Originally in ~/.inputrc with ' 's instead of ':'s
bind "\C-d":backward-word
bind "\C-f":forward-word
bind "\C-r":vi-prev-word
bind "\C-t":vi-next-word
## *
bind "\C-x":backward-kill-word
bind "\C-v":kill-word
## As with zsh, we fake small deletes *
# bind "\C-b":"\C-f \C-x"
# bind "\C-z":"\C-d \C-v"
## Oh, * are small deletes themselves!
## Use as alternative with x,v inhibited by Solaris:
bind "\C-z":backward-kill-word
bind "\C-b":kill-word
## My mirror to C-u; although default is C-k.
bind "\C-o":kill-line
## Kinda dangerous to use in case bashkeys are not loaded, because C-o's
## default is to run the current command (and load line back up into REPL)!

bind "\C-space":forward-char
bind "\C-h":backward-char
