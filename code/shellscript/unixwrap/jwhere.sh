#!/bin/sh
if jwhich whereis quietly; then
  WHERE=`jwhich whereis`
else
  WHERE="where" # shell builtin
fi
$WHERE $@

