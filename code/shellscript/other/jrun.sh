#!/bin/bash
## Was this here for Solaris?  #!/usr/local/bin/zsh

# Derive j/ path from execution of this script:
POSSJPATH=`dirname \`dirname "$0"\``

# Perform the search, with other guesses:
for JPATH in "$JPATH" "$POSSJPATH" "$HOME"/j
do
	if [ -x "$JPATH/startj" ]
	then
		. "$JPATH"/tools/startj-hwi simple
		"$@"
		exit
	fi
done

echo "jrun: Could not find your JPATH (directory containing startj)" >&2
exit 1
