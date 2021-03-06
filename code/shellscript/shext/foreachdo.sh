#!/bin/sh

# foreachdo <cmd...> will run the given command once for each line read from
# standard input, passing the line as the final argument.
#
# See also: withalldo
#
# Drawbacks: No use if you want to pass an argument *after* the one on stdin!

## CONSIDER: We can do "... | foreachdo echo", but if we do "... | foreachdo eval 'sleep 0.2 ; echo'" then it breaks on bin/org/neuralyte/irc/IRCBot$2.class .

## Oh dear ambigous naming!
## for is significantly different from while in sh
## because the latter means stdin is redirected whereas during the former it is not
## unfortnuately this "foreachdo" script /does/ steal from stdin, so it does not meet that standard
## It would be useful to have something that did, eg. when you might want to invoke vi or vimdiff each time, stdin must be free
## TODO: This could be achieved by passing the command to foralldo, so that it may execute it and capture its stdout.
##       See rememo, where eval "$COMMAND" was not quite good enough.  Consider: echo "$COMMAND" | sh, which might manage to reproduce 'command_that_processes "filename with spaces"', and then standardise / centrally document the final working method!

## Not equivalent to:
# tr "\n" "\000" | xargs -0 "$@"

## xmode can be used like this:
# find . -type f -not -size 0 | foreachdo -x mv \"\$X\" ..
## Or better:
# find . -type f -not -size 0 | foreachdo -x mv \"\$X\" ..
## poo huh?
if [ "$1" = -x ]
then XMODE=true; shift
fi

if [ "$XMODE" ]
then

	while read -r LINE
	do
		export X="$LINE"
		echo "$*" | sh
	done

else

	while read -r LINE
	do "$@" "$LINE"
	done

fi
