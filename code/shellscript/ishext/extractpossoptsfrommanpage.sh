# jsh-depends: extractregex
# jsh-ext-depends: col

printf "%s" "....." >&2

## Without jsh:
# 'man' "$@" 2> /dev/null |

## Hack for jsh:
(
	## TODO: No no no: we shouldn't just cat the file (that gets options passed to other programs!), we should use jdoc to display its --help if exists, but not show the script itself.
	[ -f "$JPATH/tools/$1" ] && head -n 200 "$JPATH/tools/$1" 2>/dev/null
	## This was causing segfaults on Hwi:
	# 'man' "$1" 2> /dev/null
	## This doesn't:
	unj man "$1" 2> /dev/null
) |

col -bx | ## strip those dirty control-chars
extractregex -atom "[ 	]((-|--)[A-Za-z0-9-=]+)" ## accepts '=', and accepts alphanums after the '=' too (often the units or the type of the value)

## Often outputs too late:
printf "%s" "     " >&2
## Unless we pause:
sleep 0
