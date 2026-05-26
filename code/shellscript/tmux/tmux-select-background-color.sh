#!/bin/sh
## Pick a tmux status-bar background colour interactively, with live preview.
## Thin wrapper around tmux-select-color.
exec tmux-select-color status-bg "$@"
