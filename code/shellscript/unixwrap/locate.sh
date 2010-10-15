#!/bin/sh
## BUG: tty checks stdin, not out :S
tty -s && PRETTY_PRINT_OK=true

[ "$1" = -pretty ] && shift && VERYPRETTY=true

`jwhich locate` "$@" |

if [ "$PRETTY_PRINT_OK" ]
then
	if [ "$VERYPRETTY" ]
	then
		## This is only really desirable if the output list is short:
		withalldo nicels -ld | highlight "$1"
	else
		highlight "$1" # really want last argument (or otherwise strip locate options)
	fi
else
	cat
fi
