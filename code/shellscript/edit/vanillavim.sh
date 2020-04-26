#!/bin/sh

# Alternative: vim -u NONE --noplugin "$@"

vanillaVimHome="$HOME/.vanilla_vim_home"

mkdir -p "$vanillaVimHome"

export HOME="$vanillaVimHome"

vim "$@"
