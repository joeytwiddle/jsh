#!/bin/sh
if endswith "$1" "\.ogg" && which ogg123 >/dev/null 2>&1
then ogg123 "$@" ; exit
# # else mpg123 -b 10000 "$@" > /dev/null 2>&1
# else unj mplayer "$@" > /dev/null 2>&1
fi

# ~/j/tools/mplayer -louder "$@" ; exit



find_exe() {
	for X
	do
		if jwhich "$X" >/dev/null 2>&1
		then echo "$X"; return
		fi
	done
}

## totem doesn't exit after it's played (but we could watch for it) - it probably won't work without X
## noatun dunno... :)

PLAYER=`find_exe mplayer-minixterm mplayer totem noatun`
unj "$PLAYER" "$@"

# mplayer "$@" |
# (
	# while read LINE
	# do
		# if [ "$LINE" = "Starting playback..." ]
		# then
			# cat
			# break
		# fi
	# done
# 
# )
