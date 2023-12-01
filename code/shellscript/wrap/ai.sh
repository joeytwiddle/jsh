#!/bin/sh
set -e

#sgpt --no-animation "$@"
#exit

if [ "$*" = "" ]
then
	sgpt --repl "$(geekdate -fine)"
	exit
fi

# --no-animation 
sgpt "$@" |

	# When reaching the width of the window, flow words onto the next line instead of breaking them
	#if command -v fold >/dev/null 2>&1
	#then fold -s -w "$COLUMNS"
	#else cat
	#fi |

	# Assume the output is markdown, and colourise it
	if command -v bat >/dev/null 2>&1
	then bat --style=plain --force-colorization --language=markdown
	else cat
	fi

