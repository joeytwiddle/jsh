#!/usr/bin/env bash

show_colors=1

dira="$1"
dirb="$2"

# -a is -rlptgoD but we don't want -t so we leave that out and use --size-only to ignore times
rsync -rlpgoD --size-only --delete -i -n "$dirb/" "$dira" |
if [ -n "$show_colors" ]
then
  highlight '^c.*' yellow |
  highlight '^>.*' green |
  highlight '^\*deleting .*' red
else cat
fi
