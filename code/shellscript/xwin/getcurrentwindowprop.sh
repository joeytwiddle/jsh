#!/usr/bin/env bash

# E.g.: getcurrentwindowprop WM_CLASS

winid="$(xdotool getwindowfocus)"

xprop -id "$winid" "$@" |
    if [ -n "$1" ]
    then
        # A specific prop was requested.  Get its value only.
        cut -d '"' -f 2
    else
        # Show all prop keys and values
        cat
    fi
