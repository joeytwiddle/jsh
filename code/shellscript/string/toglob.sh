#!/bin/sh
if [ "$*" ]
then printf "%s" "$*" | toglob
else sed ' s+\[+\\[+g ; s+\]+\\]+g '
fi
