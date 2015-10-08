#!/bin/bash
# When I stopped using memo in autocomplete_from_man, I started getting errors from here.  So I introduced the shebang.

# jsh-depends: extractregex
# jsh-ext-depends: col

if [ "$WARNJSHTOOLS" ] && [ -f "$JPATH/tools/$1" ]
then printf "%s" " `cursered`jsh`cursenorm`" >&2
fi

function unprint () {
	# [ "$SHOW_COMMAND_INFO" ] && return
	LEN=`strlen "$*"`
	for X in `seq 1 $LEN`
	do printf "%s" "" >&2
	done
	for X in `seq 1 $LEN`
	do printf "%s" " " >&2
	done
	for X in `seq 1 $LEN`
	do printf "%s" "" >&2
	done
}

# printf "%s" "....." >&2
TOPRINT="..."
printf "%s" "$TOPRINT" >&2

## Without jsh:
# 'man' "$@" 2> /dev/null |

## Hack for jsh:
(
	TOPRINT="[jdoc $1]"
	printf "%s" "$TOPRINT" >&2
	## TODO: No, we shouldn't just cat the file (that gets options passed to other programs!), we should use jdoc to display its --help if exists, but not show the script itself.
	[ -f "$JPATH/tools/$1" ] && head -n 200 "$JPATH/tools/$1" 2>/dev/null
	unprint "$TOPRINT"
	## This was causing segfaults on Hwi:
	# 'man' "$1" 2> /dev/null
	TOPRINT="[man $1]"
	printf "%s" "$TOPRINT" >&2
	## This doesn't:
	[ "$DEBUG" ] && debug "unj man \"$1\""
	unj man "$1" 2> /dev/null
	unprint "$TOPRINT"
) |

col -bx | ## strip those dirty control-chars
extractregex -atom "[ 	]((-|--)[A-Za-z0-9-=]+)" ## accepts '=', and accepts alphanums after the '=' too (often the units or the type of the value)

## Often outputs too late:
# printf "%s" "     " >&2
unprint "$TOPRINT"
## Unless we pause:
sleep 0

if [ "$WARNJSHTOOLS" ] && [ -f "$JPATH/tools/$1" ]
then printf "%s" " `cursered`jsh`cursenorm`" >&2
fi
