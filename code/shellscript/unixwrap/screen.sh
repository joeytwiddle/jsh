# export SCREEN_RUNNING=true
export DISPLAY=

## This _might_ get it to buggy if problems persist:
# export WINNAMEW
export STY

if test "$*"
then

	unj screen "$@"

else

	# echo "Once attached, press Ctrl+k then ? for help."
	unj screen -list
	# sleep 1
	echo "Type session name to attach or start new (<Enter> defaults to \"screen\")."
	read NAME
	test "$NAME" || NAME=$HOST
	test "$NAME" || NAME=screen
	# if test "$NAME"
	# then
		screen -a "-e^k^l" -S "$NAME" -D -RR
		# screen -a "-e^kk" -S "$NAME"
		# ## If screen named exists
		# if unj screen -list grep "$NAME"
		# then ## Re-attach to it:
			# screen -a "-e^kk" -D -RR "$NAME"
		# else ## Create a new one with that name
			# screen -a "-e^kk" -S "$NAME"
		# fi
	# else
		# unj screen "-e^kk" -a -D -RR
	# fi

fi
