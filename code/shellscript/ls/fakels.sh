#!/bin/sh
# This is useful for systems which do not suppoer ls --color
# but do support ls -F, so we can search for filetypes!
# It is an approximation of my basic LSCOLS of directories, executables and symlinks.
# ls -atrF -C "$@" |

# JM_LS_OPTS=`echo "$JM_LS_OPTS" | sed 's+--color\>++'`
JM_LS_OPTS=`echo "$JM_LS_OPTS" | sed 's+\(^\| \)--color\>++'`
# debug "$JM_LS_OPTS"

'ls' -atr -C $JM_LS_OPTS "$@" |
	# striptermchars |
	# On Unix this now kills the whole string!
	if test -f "$HOME/.dircolors"; then
		SEDSTR=`fakelshi`
		sed "$SEDSTR"
	else
		cat
	fi |
	# else # now always do this too:
		highlight "/" green |
		( [ "$1" = -noexec ] && highlight -bold "*" red || cat ) |
		highlight -bold "@" yellow
	# fi
