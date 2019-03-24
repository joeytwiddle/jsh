# Unfortunately if we bind <Ctrl-D> here, then it cannot be used to exit the shell.
# In fact it's a little odd that bash and zsh do allow it!
# I would be happy to bind to <Escape> b and <Escape> f, like bash and zsh defaults, but I don't know how!
# The defaults for backward-word and forward-word are Ctrl-Left and Ctrl-Right.
bind \cd backward-word
bind \cf forward-word
# Note that these are small words, not big words
bind \cr backward-word
bind \ct forward-word
#bind -k sleft backward-word
#bind -k sright forward-word
bind \cx backward-kill-word
bind \cv forward-kill-word
#bind \cz backward-kill-path-component
