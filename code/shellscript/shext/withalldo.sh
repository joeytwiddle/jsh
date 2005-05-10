# jsh-depends: error
## TODO: goes slow on long lists, presumably because of the long string manipulation.  Fix by using a stream | sh, so we can echo straight to stream instead of adding to String.

## Xargs example:
# echo 08 | xargs -i convert img{}.gif img{}.png

## One day we are going to hit too-many-arguments, and we'll need to get withalldo to do it it chunks.  But that would change functionality :-/

## Equivalent to:
# tr "\n" "\000" | xargs -0 "$@"
## Except (under gentoo kernel, debian bash) withalldo could cope when xargs complained "argument line too long".  =)

## Changed it so that you can specify --- to put the arguments in the middle of the command you call.

COMMANDLEFT=""
COMMAND=""

for ARG
do
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

while read LINE
do
	COMMANDLEFT="$COMMANDLEFT\"$LINE\" "
done

eval "$COMMANDLEFT$COMMAND"
