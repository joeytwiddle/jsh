# Originally in ~/.inputrc with ' 's instead of ':'s
bind "\C-d":backward-word
bind "\C-f":forward-word
bind "\C-r":vi-prev-word
bind "\C-t":vi-next-word
# Dammit these already are small deletes!
bind "\C-x":backward-kill-word
bind "\C-v":kill-word
# As with zsh, we fake small deletes
bind "\C-b":"\C-f \C-x"
bind "\C-z":"\C-d \C-v"
