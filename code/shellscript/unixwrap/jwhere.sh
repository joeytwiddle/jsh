#!/bin/sh
# Also of interest: type -a, where, which
# All of which will report aliases and functions if present (at least in zsh)
if jwhich whereis quietly; then
  WHERE=`jwhich whereis`
else
  WHERE="where" # shell builtin
fi
$WHERE $@

