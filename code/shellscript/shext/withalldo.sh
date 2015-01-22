#!/bin/sh

# withalldo <cmd> will run the given command once, with the lines on standard
# input passed as individual arguments.
#
# See also: foreachdo

## Does not work with BSD xargs.  As far as I can tell that has no way to delimit only on '\n'.  Therefore on BSD/OSX we should drop to the fallback.

## Pass -r option to ignore empty input (run nothing)
xargs -d '\n' "$@"
exit
# Maybe also: xargs -0 "$@"

## NOTE: One disadvantage of using xargs is that if we
## . importshfn withalldo
## and employ withalldo f where f is a shell function, xargs will not be able
## to see f!
## Recommendation: move the below to withalldosh and import *that*.

## I wrote this solution before I learned about xargs.

# jsh-depends: error

## TODO: goes slow on long lists, presumably because of the long string manipulation.  Fix by using a stream | sh, so we can echo straight to stream instead of adding to String.

## Xargs example:
# echo 08 | xargs -i convert img{}.gif img{}.png

## -0 is the safest delimiter for xargs, often used after find -print0

# ## Trying to get xargs working:
# sed  's+ +\\ +g' |
# xargs "$@" ## this seems to give up at 1024 args
# ## My xargs man page says of the --max-chars option: "The default is as large as possible, up to 20k characters."
# exit


## CONSIDER: It might be nice to automaticall striptermchars from the input stream.
## Mm it may be inefficient, but it's handy for the user :)
## But I couldn't get it working.
# striptermchars |

## One day we are going to hit too-many-arguments, and we'll need to get withalldo to do it it chunks.  But that would change functionality :-/

## Equivalent to:
# tr "\n" "\000" | xargs -0 "$@"
## Except (under gentoo kernel, debian bash) withalldo could cope when xargs complained "argument line too long".  =)

## Changed it so that you can specify --- to put the arguments in the middle of the command you call.

if [ "$1" = -r ]
then
	IGNORE_EMPTY_LIST=true
	shift
fi

slashescape () {
	sed -e "s$1\\$1g"
}

COMMANDLEFT=""
COMMAND=""

for ARG
do
	## NOTE: There are currently no scripts in jsh using the --- argument.  I recommend it be dropped.
	if [ "$ARG" = --- ]
	then
		shift
		if [ "$COMMANDLEFT" ]
		then
			error "withalldo can only accept one --- argument."
			exit 1
		fi
		COMMANDLEFT="$COMMAND"
		COMMAND=""
	else
		COMMAND="$COMMAND\"$ARG\" "
	fi
done
if [ ! "$COMMANDLEFT" ]
then
	COMMANDLEFT="$COMMAND"
	COMMAND=""
fi

## Failed fix for: ~/.xchat2.nogginBasher/xchatlogs/ % echolines * | grep -v "#" | withalldo jzcat

# slashescape '`' |
# sed 's+`+\\`+g' |

while read LINE
do
	COMMANDLEFT="$COMMANDLEFT\"$LINE\" "
done

if [ -z "$COMMANDLEFT" ] && [ "$IGNORE_EMPTY_LIST" ]
then :
else
	# debug "withalldo: eval \"$COMMANDLEFT $COMMAND\""
	eval "$COMMANDLEFT$COMMAND"
fi

