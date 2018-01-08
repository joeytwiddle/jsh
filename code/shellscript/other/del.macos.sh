#!/bin/bash

# Based on: https://apple.stackexchange.com/questions/50844/how-to-move-files-to-trash-from-command-line#79032

move_to_trash () {
  local path
  for path in "$@"; do
    # ignore any arguments
    if [[ "$path" = -* ]]; then
      :
    else
      # remove trailing slash
      local mindtrailingslash="${path%/}"
      # remove preceding directory path
      local dst="${mindtrailingslash##*/}"
      # append the time if necessary
      while [ -e ~/.Trash/"$dst" ]; do
        #dst="`expr "$dst" : '\(.*\)\.[^.]*'` `date +%H-%M-%S`.`expr "$dst" : '.*\.\([^.]*\)'`"
        dst="$dst.$(date +"%Y%m%d-%H%M%S")"
      done
      printf "%s\n" "$path -> ~/.Trash/$dst"
      mv "$path" "$HOME/.Trash/$dst"
    fi
  done
}

move_to_trash "$@"
