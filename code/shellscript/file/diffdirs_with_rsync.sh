#!/usr/bin/env bash

show_colors=1

dira="$1"
dirb="$2"

rsync -ai --delete -n "$dirb/" "$dira/" |
if [ -n "$show_colors" ]
then
  highlight '^c.*' yellow |
  highlight '^>.*' green |
  highlight '^\*deleting .*' red
else cat
fi
