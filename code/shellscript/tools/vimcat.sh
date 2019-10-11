#!/bin/bash

vimcat="$HOME/.vim-addon-manager/github-rkitover-vimpager/vimcat" 

# This function contains all the common options, so we don't have to repeat them below.
# We use $realhome just in case we have changed $HOME below.
realhome="$HOME"
run_vimcat() {
  # -o - will force colour output even if output is not to a tty (e.g. we are piping to |more)
  # Instead of putting commands here, we could put them in ~/.vimcatrc
  #-c "so ~/.vim/plugin/joeysyntax.vim" -c "so ~/.vim/plugin/joeyhighlight.vim" "$@"
  #-c "so ~/.vim/plugin/joeyhighlight.vim" 
  "$vimcat" -c "set cmdheight=50" -c "so $realhome/.vim-addon-manager/github-sheerun-vim-polyglot/syntax/javascript.vim" -c "so $realhome/.vim/after/syntax/javascript.vim" -c "so $realhome/.vim/colors_for_elvin_gentlemary.vim" -c 'hi! clear Normal' -o - "$@"
}

# Normal way of running
#run_vimcat "$@"

# But I don't want to load my usual .vimrc or plugins, because that slows vim down a lot.
# TODO: Perhaps a better solution would be to load only those scripts needed for syntax highlighting (ftdetect, syntax, ...?) and skip the rest.

# This skips loading .vimrc but it will still load plugins
#run_vimcat -u <(:) "$@"

# We should be able to prevent plugins from loading using --noplugin, but vimcat was rejecting it!
#run_vimcat -u <(:) --noplugin "$@"

# Changing our home folder will prevent loading of the usual .vimrc and our usual plugins
export HOME="$realhome/.vanillavim"

# On macOS, this did not show newlines correctly
#run_vimcat "$@" > /tmp/out

# But this works on macOS!
run_vimcat "$@" > /tmp/out
cat /tmp/out

# But also on macOS, it doesn't seem to load the gentlemary colors
